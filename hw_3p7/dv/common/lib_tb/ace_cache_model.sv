////////////////////////////////////////////////////////////////////////////////
//
// ACE Cache Model
//
////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////// 
// TODO List:
// 1) Make addresses cache-line aligned only
///////////////////////////////////////////////////////////////////////// 

//Base class for generating Cachelines
class ace_cache_line_model extends uvm_object;

    bit [addrMgrConst::ADDR_WIDTH-1:0]    m_addr; 
    addrMgrConst::aceState_t              m_state;         
    bit [<%=obj.wSecurityAttribute%>-1:0] m_security;
    bit [addrMgrConst::DATA_WIDTH-1:0]    m_data[];
    bit m_non_coherent_addr;

    `uvm_object_param_utils_begin  (ace_cache_line_model)
        `uvm_field_int       (m_addr, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       (m_security, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum      (addrMgrConst::aceState_t, m_state, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int (m_data, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

 
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "ace_cache_line_model");
        super.new(name);
    endfunction : new

    //------------------------------------------------------------------------------
    // Copy Method
    //------------------------------------------------------------------------------
    function void do_copy(uvm_object rhs);
        ace_cache_line_model rhs_;

        if(!$cast(rhs_, rhs)) 
            `uvm_fatal("ADDR MGR", "Unable to cast")
        super.do_copy(rhs);

        m_addr = rhs_.m_addr;
        m_state = rhs_.m_state;

    endfunction: do_copy

    //Virtual method for exttended class
     function  int set_memregion_id(int idx);
        return(idx);
    endfunction: set_memregion_id


    //Randomize the cacheline obj
     function void gen_cacheline(int funitid,
                                bit dont_constrain_addr,
                                bit [1:0] addr_boundaries = 2'h0);
    endfunction: gen_cacheline

    function bit[addrMgrConst::ADDR_WIDTH-1:0] get_cacheline();
        get_cacheline = m_addr;
    endfunction: get_cacheline

    function bit [addrMgrConst::WCACHE_TAG-1:0] get_cache_tag();
        get_cache_tag = m_addr[addrMgrConst::ADDR_WIDTH-1:addrMgrConst::WCACHE_OFFSET];
    endfunction: get_cache_tag

    function bit [addrMgrConst::ADDR_WIDTH-1:0] get_cache_aligned_addr();
        get_cache_aligned_addr = m_addr[addrMgrConst::ADDR_WIDTH-1:addrMgrConst::WCACHE_OFFSET];
        get_cache_aligned_addr = get_cache_aligned_addr << addrMgrConst::WCACHE_OFFSET;
    endfunction: get_cache_aligned_addr

    function void set_cachceline_addr(bit [63:0] m_addr);
        this.m_addr = 0;
        this.m_addr = m_addr;
    endfunction: set_cachceline_addr

    //------------------------------------------------------------------------------
    // Print function 
    //------------------------------------------------------------------------------
    function string sprint_pkt();
        sprint_pkt = $sformatf("Addr:0x%0x Secure:%0b State:%0p NonCohAddr:%0b Data0:0x%0x"
        , m_addr, m_security, m_state, m_non_coherent_addr, m_data[0]);
        for (int i = 1; i < m_data.size; i++) begin
            sprint_pkt = {sprint_pkt, $sformatf("Data%0d:0x%0x"
            , i, m_data[i])};
        end
    endfunction : sprint_pkt

    function void randomize_data();
        m_data = new[addrMgrConst::MAX_BEATS_CACHELINE];
        for (int i = 0; i < m_data.size(); i++) begin
            bit [addrMgrConst::DATA_WIDTH-1:0] tmp;
            assert(std::randomize(tmp));
            m_data[i] = tmp;
            if (m_data[i] == '0) begin
                $stacktrace();uvm_report_error(get_name(), $sformatf("Data Randomization of ace cache line failed"), UVM_NONE);
            end
        end
    endfunction: randomize_data 

endclass: ace_cache_line_model




typedef bit [2:0] state_queue_t[$];
class end_state_queue_t;
    state_queue_t m_end_state_queue_t[2:0];
endclass : end_state_queue_t
class start_state_queue_t;
    state_queue_t m_start_state_queue_t[1:0];
endclass : start_state_queue_t 

typedef struct {
    time                                                t_creation;
    bit                                                 isRead;   // 1:Read 0:Write
    bit                                                 isUpdate; 
    ace_command_types_enum_t m_cmdtype;
    bit                                                 isReqInFlight;
    bit                                                 isCohWriteSent; //can be set for WRUNQ, WRLNUNQ, MemUpds
    axi_axaddr_t             m_addr;
    <%if (obj.wSecurityAttribute > 0){%>
        bit [<%=obj.wSecurityAttribute%>-1:0]           m_security;
    <%}%>                                                
    axi_xdata_t              m_data[];
    bit isNonCoh;
} ORT_struct_t;

typedef struct {
    axi_axaddr_t m_addr;
    <%if(obj.wSecurityAttribute > 0) { %>                                             
        bit [<%=obj.wSecurityAttribute%>-1:0]   m_security;
    <%}%>
    aceState_t   m_end_state;
    bit m_update_in_progress_and_responding_with_IS1PD0;
} STT_struct_t;

<% if((obj.Block === 'io_aiu') || (obj.Block === 'aiu') || (obj.Block === 'mem' && obj.is_master === 1)) { %>   
    class ace_cache_model extends uvm_object;

        `uvm_object_param_utils(ace_cache_model)

        uvm_cmdline_processor clp;
        ace_cache_line_model m_cache[$];
        int                  size_of_cache_limit;
        // Below queue is used to keep outstanding requests for addresses already in cache
        ORT_struct_t         m_ort[$];
        // Below queue is used to keep outstanding snoops  
        STT_struct_t         m_stt[$];
        
        int outstanding_dvm_axidq[$];

        <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ace_coverage cov;
        `endif
        <%}%>
        
<%if (obj.testBench == "fsys") {%>
        bit    GEN_SEL_TARG_ADDR;  
        string test_targ_unit_type = "DII"; /* "DII" OR "DMI" */
        int    test_targ_unit_id=0; /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
        int    test_targ_index_in_group=0; /*For multiple mem region configured for any DII or DMI, select one of them.*/
        bit    test_targ_nc=1; /* Non-coherent or coherent region */
<% } %>
        //Required to cast to addr_trans_mgr enum
        addrMgrConst::aceState_t tmp_aceState;

        // Knobs
        int wt_expected_end_state               = 60;
        int wt_legal_end_state_with_sf          = 25;
        int wt_legal_end_state_without_sf       = 15;
        int wt_expected_start_state             = 60;
        int wt_legal_start_state                = 40;
        int wt_lose_cache_line_on_snps          = 20;
        int wt_keep_drty_cache_line_on_snps     = 50;
        int prob_respond_to_snoop_coll_with_wr  = 50;
        int prob_was_unique_snp_resp            = 50;
        int prob_unq_cln_to_unq_dirty           = 70;
        int prob_unq_cln_to_invalid             = 10;
        int prob_was_unique_always0_snp_resp    = 25;
        int prob_dataxfer_snp_resp_on_clean_hit = 10;
        int prob_ace_wr_ix_start_state          = 80;
        int prob_ace_rd_ix_start_state          = 80;
        int prob_cache_flush_mode_per_1k        = 100;
        int prob_ace_coh_win_error              = 0;
        int prob_ace_snp_resp_error             = 0;
        int prob_of_new_addr                    = 25;
        int prob_of_dmi_dii_addr                = 50;
        int prob_of_new_set                     = 101;
        int size_of_wr_queue_before_flush       = 10;
        int total_outstanding_coh_writes        = 3;
        int total_min_ace_cache_size            = 50;
        int total_max_ace_cache_size            = 150;
        bit prot_rand_disable                   = 0;
        bit	cache_model_dbg_en 					= 0;
    
        // newperf_test to allow loop. hence we are able to manage hit & miss
        int use_loop_addr; // nbr of addr before loop
        int use_loop_addr_offset; // addr_offset = nbr of miss

        //testing DII CMOs 
        int dii_cmo_test = 0;
        // Supporting variables to count OTT entries for performance monitor verification
        const int   max_number_of_outstanding_txn = <%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%>-2;


        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
            int wt_ace_wrcln                        = 5;
            int wt_ace_wrbk                         = 5;
            int wt_ace_wrevct                       = 5;
            int wt_ace_evct                         = 5;
        <%}%>

        int val_was_unique_always0_snp_resp     = 0;
        addr_trans_mgr                          m_addr_mgr;
        int funitid = 0;
        int core_id = 0;
        bit [2:0] unit_unconnected;

        addrMgrConst::addrq user_addrq[];
        static int user_addrq_idx[];
        addrMgrConst::addrq user_write_addrq[];
        static int user_write_addrq_idx[];
        addrMgrConst::addrq user_read_addrq[];
        static int user_read_addrq_idx[];

        event     e_ort_delete;
        bit       iocache_perf_test = 0;



        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.fnNativeInterface == "AXI5" || (obj.Block === 'mem' && obj.is_master === 1)) { %>
            event     e_cache_add;
            event     e_cache_modify;
            int       count_till_end_of_coh_req;
            bit       cache_flush_mode_on;
            bit       pwrmgt_cache_flush;
            bit       coh_write_seq_active = 0;
            semaphore s_coh_noncoh = new(1);
            bit       end_of_sim = 0;
        <%}%>

        int num_trans_per_chi;
        int num_trans_per_ioaiu;

        //------------------------------------------------------------------------------
        // Constructor
        //------------------------------------------------------------------------------

        function new(string name = "ace_cache_state_model");
            string arg_value;
            addrMgrConst::addr_format_t f;
            prot_rand_disable = ($urandom_range(0,100) > 75);
            
            <% if (obj.Block === "mem") { %>
                funitid = <%=obj.nAIUs + obj.nCBIs + 1%>;
            <% } else { %>
                funitid = <%=obj.AiuInfo[obj.Id].FUnitId%>;
            <% } %>
            m_addr_mgr = addr_trans_mgr::get_instance();

            if ($urandom_range(0,100) < prob_was_unique_always0_snp_resp) begin
                val_was_unique_always0_snp_resp = 1;
            end
            else begin
                val_was_unique_always0_snp_resp = 0;
            end
            size_of_cache_limit = total_max_ace_cache_size;
            clp = uvm_cmdline_processor::get_inst();
            clp.get_arg_value("+UVM_TESTNAME=", arg_value);
            if (arg_value == "concerto_inhouse_iocache_perf_test") begin
                iocache_perf_test = 1;
            end
            else begin
                iocache_perf_test = 0;
            end
            if (arg_value == "concerto_conc_2292_test") begin
                prot_rand_disable = 1;
            end
            if ($test$plusargs("prot_rand_disable")) begin
                prot_rand_disable = 1;
            end

            if (clp.get_arg_value("+prob_of_new_addr=", arg_value)) begin
                prob_of_new_addr = arg_value.atoi();
            end
            else begin
                randcase
                    30: prob_of_new_addr = 0;
                    40: prob_of_new_addr = $urandom_range(5,25); 
                    30: prob_of_new_addr = $urandom_range(25,100);
                endcase
            end

            if (clp.get_arg_value("+prob_of_dmi_dii_addr=", arg_value)) begin
                prob_of_dmi_dii_addr = arg_value.atoi();
            end
            else begin
                randcase
                    30: prob_of_dmi_dii_addr = 0;
                    40: prob_of_dmi_dii_addr = $urandom_range(40,60);
                    30: prob_of_dmi_dii_addr = 100;
                endcase
            end
            if ($test$plusargs("hit_streaming_strreqs")) begin
                prob_of_new_addr = 25;
            end
    
            //newperf_test new plusargs to allow percentage of miss
            //for example:  loop_addr=100  & loop_addr_offset=10 with user_addrq =1000
            //=> 10 loops of 100 addr  with first loop 100% miss & 9 loop with 10% of miss
            //use plusargs doff_xx in newperf scoreboard to remove the first loop to calculate the BW 
            if(!$value$plusargs("use_loop_addr=%d",use_loop_addr)) begin
                    use_loop_addr = 0;
            end
            if(!$value$plusargs("use_loop_addr_offset=%d",use_loop_addr_offset)) begin
                    use_loop_addr_offset = 0;
            end
            //newperf_test 
            user_addrq = new[f.num()];
            user_addrq_idx = new[f.num()];
            user_write_addrq = new[f.num()];
            user_write_addrq_idx = new[f.num()];
            user_read_addrq = new[f.num()];
            user_read_addrq_idx = new[f.num()];

            if ($test$plusargs("use_seq_user_addrq")) begin
                foreach (user_addrq_idx[i])
                    user_addrq_idx[i] = 0;
                foreach (user_write_addrq_idx[i])
                    user_write_addrq_idx[i] = 0;
                foreach (user_read_addrq_idx[i])
                    user_read_addrq_idx[i] = 0;
            end else begin
                foreach (user_addrq_idx[i])
                    user_addrq_idx[i] = -1;
                foreach (user_write_addrq_idx[i])
                    user_write_addrq_idx[i] = -1;
                foreach (user_read_addrq_idx[i])
                    user_read_addrq_idx[i] = -1;
            end
            
            <% if(obj.COVER_ON) { %>
            cov=new();
            <%}%>
            //testing DII CMOs
            if(!$value$plusargs("dii_cmo_test=%d",dii_cmo_test)) begin
                dii_cmo_test = 0;
            end

            if(!$value$plusargs("chi_num_trans=%d",num_trans_per_chi)) begin
                num_trans_per_chi = 1000;
            end
            if(!$value$plusargs("ioaiu_num_trans=%d",num_trans_per_ioaiu)) begin
                num_trans_per_ioaiu = 1000;
            end
             if($test$plusargs("force_we_noncoh")) begin
               int   m_tmp_q[$];
               for(int idx=0; idx < 100; idx++) begin
                  ace_cache_line_model  m_cache_line = new();
                  m_cache_line.m_non_coherent_addr = 1;
                  if (idx<50) begin
                     m_cache_line.m_addr=m_addr_mgr.get_noncoh_addr(funitid,1,core_id);
                     m_cache_line.m_state = addrMgrConst::aceState_t'(ACE_UC);
                   `uvm_info("CACHE_NONCOH_DMI", m_cache_line.sprint_pkt(), UVM_LOW);
                  end else begin
                     m_cache_line.m_addr=m_addr_mgr.get_iocoh_addr(funitid, 1, core_id);
                     m_cache_line.m_state = addrMgrConst::aceState_t'(ACE_UC);
                   `uvm_info("CACHE_NONCOH_DII", m_cache_line.sprint_pkt(), UVM_LOW);
                  end
                  m_tmp_q = {};
                  m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == m_cache_line.m_addr[WAXADDR-1:SYS_wSysCacheline]);
                  if (m_tmp_q.size()==0) begin
                    m_cache.push_back(m_cache_line);
                  end
               end
             end
             if($test$plusargs("force_wb_wc_noncoh")) begin
               int   m_tmp_q[$];
               for(int idx=0; idx < 100; idx++) begin
                  ace_cache_line_model  m_cache_line = new();
                  m_cache_line.m_non_coherent_addr = 1;
                  if (idx<50) begin
                     m_cache_line.m_addr=m_addr_mgr.get_noncoh_addr(funitid,1,core_id);
                     randcase 
                         50: m_cache_line.m_state = addrMgrConst::aceState_t'(ACE_SD);
                         50: m_cache_line.m_state = addrMgrConst::aceState_t'(ACE_UD);
                     endcase
                   `uvm_info("CACHE_NONCOH_DMI", m_cache_line.sprint_pkt(), UVM_NONE);
                  end else begin
                     m_cache_line.m_addr=m_addr_mgr.get_iocoh_addr(funitid, 1, core_id);
                     randcase 
                         50: m_cache_line.m_state = addrMgrConst::aceState_t'(ACE_SD);
                         50: m_cache_line.m_state = addrMgrConst::aceState_t'(ACE_UD);
                     endcase
                   `uvm_info("CACHE_NONCOH_DII", m_cache_line.sprint_pkt(), UVM_NONE);
                  end
                  m_tmp_q = {};
                  m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == m_cache_line.m_addr[WAXADDR-1:SYS_wSysCacheline]);
                  if (m_tmp_q.size()==0) begin
                    m_cache.push_back(m_cache_line);
                  end
               end
            end
    
<%if (obj.testBench == "fsys") {%>
            if(!$value$plusargs("GEN_SEL_TARG_ADDR=%0b",GEN_SEL_TARG_ADDR)) begin
                GEN_SEL_TARG_ADDR = 0;
            end
            if(!$value$plusargs("test_targ_unit_type=%0s",test_targ_unit_type)) begin
                test_targ_unit_type = "DII"; /* "DII" OR "DMI" */
            end
            if(!$value$plusargs("test_targ_unit_id=%0d",test_targ_unit_id)) begin
                test_targ_unit_id=0; /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
            end
            if(!$value$plusargs("test_targ_index_in_group=%0d",test_targ_index_in_group)) begin
                test_targ_index_in_group=0; /*For multiple mem region configured for any DII or DMI, select one of them.*/
            end
            if(!$value$plusargs("test_targ_nc=%0d",test_targ_nc)) begin
                test_targ_nc=1;
            end
<% } %>
        endfunction : new
        
        function bit[addrMgrConst::ADDR_WIDTH-1:0] gen_new_cacheline(int funitid, int en_funitid, int core_id=0);
            bit [addrMgrConst::ADDR_WIDTH-1:0] sec_addr;
            int addr_set,cur_addr_set;
            int fnmem_region_idx,dest_id;
            int lid, cid;
            int xsum;

            <%if(obj.Block == "io_aiu") { %>
                lid = <%=obj.Id%>;
            <% } else { %>
                lid = <%=obj.Id%>;
            <% } %>			      
            if($urandom_range(1,100) < prob_of_new_set) begin
                    sec_addr = m_addr_mgr.gen_coh_addr(funitid, en_funitid, -1, -1, -1, -1, core_id);
            end
            else begin
                addr_set = 0;
                sec_addr = m_addr_mgr.gen_coh_addr(funitid,1,
                                addrMgrConst::funit_ids[addrMgrConst::dmi_ids[0]],
                                -1,
                                -1,addr_set, core_id);
                cur_addr_set = m_addr_mgr.get_set_index(addrMgrConst::funit_ids[addrMgrConst::dmi_ids[0]],1,sec_addr);
                if(cur_addr_set != addr_set) begin
                    foreach (addrMgrConst::cbi_set_sel[lid].pri_bits[i]) begin
                        sec_addr[addrMgrConst::cbi_set_sel[lid].pri_bits[i]] = addr_set[i];
                        xsum = 0;
                        foreach (addrMgrConst::cbi_set_sel[lid].sec_bits[i,j]) begin
                            xsum = xsum ^ sec_addr[addrMgrConst::cbi_set_sel[lid].sec_bits[i][j]];
                        end
                        sec_addr[addrMgrConst::cbi_set_sel[lid].sec_bits[i][0]] = xsum ^ addr_set[i];
                    end
                end
                addr_set = m_addr_mgr.get_set_index(addrMgrConst::funit_ids[addrMgrConst::dmi_ids[0]],1,sec_addr);
            end // else: !if($urandom_range(1,100) < prob_of_new_set)
            m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, funitid); 											
            return sec_addr;
        endfunction: gen_new_cacheline

        function bit is_read_chnl_txn(ace_command_types_enum_t cmdtype);

            if (cmdtype inside {RDNOSNP, 
                                RDONCE, RDSHRD, RDCLN, RDNOTSHRDDIR, RDUNQ, CLNUNQ, MKUNQ, 
                                CLNSHRD, CLNSHRDPERSIST, CLNINVL, MKINVL, 
                                RDONCECLNINVLD, RDONCEMAKEINVLD})
                return 1;
            else 
                return 0;
        endfunction: is_read_chnl_txn
        
        function bit is_write_chnl_txn(ace_command_types_enum_t cmdtype);
            if (cmdtype inside {WRNOSNP, 
                                WRUNQ, WRLNUNQ, 
                                WRBK, WRCLN, WREVCT, EVCT, 
                                ATMLD, ATMSTR, ATMSWAP, ATMCOMPARE,
                                WRUNQPTLSTASH, WRUNQFULLSTASH, STASHONCESHARED, STASHONCEUNQ})
                return 1;
            else 
                return 0;
        endfunction: is_write_chnl_txn        

        //TODO: Take care of resp errors below 
        function void modify_cache_line(axi_axaddr_t addr,
                                        ace_command_types_enum_t cmdtype,
                                        axi_bresp_t resp[],
                                        axi_xdata_t data[],
                                        axi_axburst_t burst = AXIINCR,
                                        axi_axsize_t size = WLOGXDATA,
                                        bit isShared = 0,
                                        bit PassDirty = 0,
                                        bit isExclPass = 0,
                                        bit awunique = 0,
                                        axi_axdomain_t axdomain
                                        <%if(obj.wSecurityAttribute > 0){%>                                             
                                            ,inout bit[<%=obj.wSecurityAttribute%>-1:0] security
                                        <%}%>);
            aceState_t m_start_state;
            aceState_t m_end_state;
            int                                   m_tmp_q[$];
            int                                   m_tmp_qA[$];
            ace_cache_line_model                  m_cache_line = new();
            string                                arg_value; 
            int                                   len;
            bit                                   power_test;

            // For a power test, we do not want rdnosnp to install a line in non-IX because it cannot be flushed (by sending a wrnosnp)
            // in the flush sequence currently
            power_test = 0;
            clp.get_arg_value("+UVM_TESTNAME=", arg_value);
            len = arg_value.len();
            for (int i = 0; i < len; i++) begin
                if (arg_value.substr(i,i+5-1) == "power") begin
                    power_test = 1;
                end
            end

            // Not updating data for an exclusive fail
            // Not updating data for a DECERR
            // CONC-11827 dont change cacheline state
            if (!(((cmdtype == CLNUNQ || cmdtype == RDCLN || cmdtype == RDSHRD) && isExclPass == 0) || ((resp[0] inside {SLVERR,DECERR}) && !(cmdtype inside {WRBK, WREVCT,EVCT})))) begin
                m_start_state = current_cache_state(addr
                <%if(obj.wSecurityAttribute > 0){%>
                    ,security
                <%}%>);
            
                <%if(obj.testBench === "aiu"){%>
                    if(!(cmdtype == WRBK || 
                        cmdtype == WRCLN || 
                        cmdtype == WREVCT || 
                        cmdtype == EVCT))begin
                        randcase
                            50: m_end_state = ACE_SC;
                            25: m_end_state = ACE_UD;
                            25: m_end_state = ACE_UC;
                            25: m_end_state = ACE_IX;
                        endcase
                    end
                    else begin
                    m_end_state = calculate_end_state(cmdtype, m_start_state, addr, isShared, PassDirty); 
                    end
                <%}else{%>
                    if(axdomain == NONSHRBL &&
                    (cmdtype == WRBK     ||
                        cmdtype == WREVCT)
                    ) begin
                        m_end_state = ACE_IX;
                    end else if (axdomain == NONSHRBL && cmdtype == WRCLN) begin
                        m_end_state = ACE_UC;
                   end else begin
                        m_end_state = calculate_end_state(cmdtype, m_start_state, addr, isShared, PassDirty);
                    end
                <%}%>

                if (cmdtype == WRUNQ ||
                    cmdtype == WRLNUNQ
                ) begin
                    if (awunique ||
                    m_start_state == ACE_IX) begin
                        m_end_state = ACE_IX;
                    end
                    else begin
                        m_end_state = ACE_SC;
                    end
                end
                if (power_test && (cmdtype === RDNOSNP ||
                cmdtype === WRNOSNP)) begin
                    m_end_state = ACE_IX;
                end
                <% if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
                if(axdomain == NONSHRBL ||
                axdomain == SYSTEM) begin
                    m_end_state = m_start_state; //Non-coherent transaction will not cause CL state change
                end
                <%}%>
                // Silent upgrade UC->UD 
                if (m_end_state == ACE_UC) begin
                    if($urandom_range(0,100) < prob_unq_cln_to_unq_dirty) begin
                        m_end_state = ACE_UD;
                        `uvm_info("CACHE State Change", $sformatf("Cache line state changed silently from ACE_UC to ACE_UD for address 0x%0x security 0x%0x", addr, 
                                    <%if(obj.wSecurityAttribute>0){%>
                                        security
                                    <%}else{%>
                                        0
                                    <%}%>), UVM_LOW);
                    end 
                end

                // Silent evict UC->IX 
                if (m_end_state == ACE_UC) begin
                    if($urandom_range(0,100) < prob_unq_cln_to_invalid) begin
                        m_end_state = ACE_IX;
                        `uvm_info("CACHE State Change", $sformatf("Cache line state changed silently from ACE_UC to ACE_IX for address 0x%0x security 0x%0x", addr, 
                                <%if(obj.wSecurityAttribute>0){%>
                                    security
                                <%}else{%>
                                    0
                                <%}%>), UVM_LOW);
                    end
                end

                `uvm_info($sformatf("ACE CACHE MODEL - Change Cacheline State %s", get_full_name()), $sformatf("Changing cache line state for address 0x%0x security 0x%0x for cmdtype %s from start state %0p to end state %0p", addr 
                    <%if(obj.wSecurityAttribute > 0){%>
                        ,security,
                    <%}else{%>
                        ,0,
                    <%}%>cmdtype.name(), m_start_state, m_end_state), UVM_LOW); 
                m_tmp_q = {};
                m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                <%if(obj.wSecurityAttribute > 0){%>
                    && item.m_security == security
                <%}%>);
                if (m_end_state == ACE_IX) begin
                    if (m_tmp_q.size() == 1) begin
                        m_cache.delete(m_tmp_q[0]);
                    end
                    //not required to install null cacheline, it causes multiple 0 entries CONC-13920
                    //m_cache.push_back(m_cache_line);
                    <% if (obj.fnNativeInterface == "ACE"  || obj.fnNativeInterface == "ACE5") { %>    
                        ->e_cache_modify;
                    <% } %>                                                
                end
                else begin
                    m_cache_line.m_addr       = addr;
                    <%if(obj.wSecurityAttribute > 0){%>
                        m_cache_line.m_security = security;
                    <%}%>
                    m_cache_line.m_data       = new[SYS_nSysCacheline*8/WXDATA];
                    if(!$cast(tmp_aceState, m_end_state))
                        `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
                    m_cache_line.m_state = tmp_aceState;
                    // If ace request is of the following types, no data will be seen on the read response and data will remain the same 
                    if ((cmdtype == CLNSHRD) ||
                        (cmdtype == CLNUNQ)  ||
                        (cmdtype == CLNINVL) ||
                        (cmdtype == MKINVL)  ||
                        (cmdtype == MKUNQ)   
                    ) begin
                        if (m_tmp_q.size() != 0) begin
                            m_cache_line.m_data = m_cache[m_tmp_q[0]].m_data;
                        end
                    end
                    else begin
                        if ((cmdtype == RDNOSNP)      || 
                            (cmdtype == RDONCE)       || 
                            (cmdtype == RDCLN)        || 
                            (cmdtype == RDNOTSHRDDIR) || 
                            (cmdtype == RDSHRD)       || 
                            (cmdtype == RDUNQ)
                        ) begin
                            // Aligning data to be cacheline aligned
                            int beat_count_of_req = addr[SYS_wSysCacheline-1:WLOGXDATA];
                            // Keep cached copy of data if I have it and only use read data if line is not in cache
                            if (m_start_state == ACE_IX) begin
                                foreach (data[i]) begin
                                    m_cache_line.m_data[beat_count_of_req] = data[i];
                                    if (beat_count_of_req == SYS_nSysCacheline*8/WXDATA - 1) begin
                                        beat_count_of_req = 0;
                                    end
                                    else begin
                                        beat_count_of_req++;
                                    end
                                end
                            end
                            else begin
                                m_cache_line.m_data = m_cache[m_tmp_q[0]].m_data;
                            end
                        end
                        else begin
                            if (m_tmp_q.size() != 0) begin
                                m_cache_line.m_data = m_cache[m_tmp_q[0]].m_data;
                                if (cmdtype == WRLNUNQ ||
                                    cmdtype == WRUNQ
                                ) begin
                                    m_tmp_qA = {};
                                    m_tmp_qA = m_ort.find_first_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                                    <%if(obj.wSecurityAttribute > 0){%>
                                        && item.m_security == security
                                    <%}%>);
                                    if (m_tmp_qA.size == 0) begin
                                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: 1 Outstanding request queue does not have address even though we are modifying it for ACE request type %0s (address: 0x%0x)", cmdtype.name(), addr), UVM_NONE);
                                    end
                                    else begin
                                        int beat_count_of_req_tmp;
                                        bit is_data_capture_done = 0; 
                                        beat_count_of_req_tmp = addr[SYS_wSysCacheline-1:WLOGXDATA];
                                        // Handling weird wrap case 
                                        if (burst == AXIWRAP) begin
                                            longint start_addr     = (addr/(WXDATA/8)) * ( WXDATA/8);
                                            int num_bytes          = 2 ** size;
                                            int burst_length       = m_ort[m_tmp_qA[0]].m_data.size();
                                            longint aligned_addr   = (start_addr/(num_bytes)) * num_bytes;
                                            int dt_size            = num_bytes * burst_length;
                                            longint lower_boundary = (start_addr/(dt_size)) * dt_size;
                                            longint upper_boundary = lower_boundary + dt_size;
                                            int beat_count         = 0;
                                            if ((dt_size < SYS_nSysCacheline) &&  
                                                (lower_boundary < ((addr/(WXDATA/8)) * (WXDATA/8))) 
                                            ) begin
                                                int j = 0;
                                                is_data_capture_done = 1;
                                                for (int i = 0; i < m_ort[m_tmp_qA[0]].m_data.size(); i++) begin 
                                                    m_cache_line.m_data[beat_count_of_req_tmp] = m_ort[m_tmp_qA[0]].m_data[i];
                                                    start_addr = start_addr + num_bytes;
                                                    if (start_addr >= upper_boundary && beat_count == 0) begin
                                                        beat_count = m_ort[m_tmp_qA[0]].m_data.size() - i;
                                                        beat_count_of_req_tmp = lower_boundary[SYS_wSysCacheline-1:WLOGXDATA] - 1;
                                                    end
                                                    beat_count_of_req_tmp++;
                                                    if (beat_count_of_req_tmp == SYS_nSysCacheline*8/WXDATA) begin
                                                        beat_count_of_req_tmp = 0;
                                                    end
                                                end
                                                //uvm_report_info("CHIRAG ACE$MODEL", $sformatf("END Address 0x%0x Data to copy from %0p cacheline data %0p", addr, m_ort[m_tmp_qA[0]].m_data, m_cache_line.m_data), UVM_NONE);
                                            end
                                        end
                                        if (!is_data_capture_done) begin
                                            foreach(m_ort[m_tmp_qA[0]].m_data[l]) begin
                                                m_cache_line.m_data[beat_count_of_req_tmp] = m_ort[m_tmp_qA[0]].m_data[l];
                                                //uvm_report_info("CHIRAG WR RESP DATA UPDATE", $sformatf("Address:0x%0x l:0x%0x beat count: 0x%0x data[l]:0x%0x cacheline data:0x%0x cache data: 0x%0x", addr, l, beat_count_of_req_tmp, data[l], m_cache_line.m_data[beat_count_of_req_tmp], m_cache[m_tmp_q[0]].m_data[beat_count_of_req_tmp]), UVM_NONE);
                                                if (beat_count_of_req_tmp == SYS_nSysCacheline*8/WXDATA - 1) begin
                                                    beat_count_of_req_tmp = 0;
                                                end
                                                else begin
                                                    beat_count_of_req_tmp++;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if (m_end_state == ACE_UD) begin
                        m_cache_line.randomize_data();
                    end
                    if(axdomain inside {NONSHRBL, SYSTEM}) begin
                        m_cache_line.m_non_coherent_addr = 1;
                    end
                    else begin
                        m_cache_line.m_non_coherent_addr = 0;
                    end
                    // Installing line in cache
                    if (m_tmp_q.size() == 1) begin
                        m_cache.delete(m_tmp_q[0]);
                    end
                    m_cache.push_back(m_cache_line);
                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                        ->e_cache_add;
                        ->e_cache_modify;
                    <%}%>
                end
            end else begin 

                //`uvm_info($sformatf("ACE CACHE MODEL - Change Cacheline State %s", get_full_name()), $sformatf("No change in cache line state for address 0x%0x security 0x%0x for cmdtype:%s from start_state:%0p end_state:%0p", addr
                //    <%if(obj.wSecurityAttribute > 0){%>
                //        ,security,
                //    <%}else{%>
                //        ,0,
                //    <%}%>cmdtype.name(), m_start_state, m_end_state), UVM_LOW); 

            end 
            m_tmp_q = {};
            m_tmp_q = m_ort.find_first_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
            <%if(obj.wSecurityAttribute > 0) { %>                                             
                && item.m_security == security
            <%}%>
            && item.m_cmdtype == cmdtype);
            if (m_tmp_q.size == 0) begin
                foreach(m_ort[i]) begin
                    `uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("%0p", m_ort[i]), UVM_NONE);
                end
                $stacktrace();
                `uvm_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Outstanding request queue does not have address even though we are modifying it for ACE request type %0s (address: 0x%0x)", cmdtype.name(), addr));
            end
            else begin
                m_ort.delete(m_tmp_q[0]);
                <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                    ->e_cache_modify;
                <% } %>                                                
                ->e_ort_delete;
            end

            //For ACE-AIU indicated address manager that cacheline
            //is evicted from L1-cache
            //informing address manager that response for cacheline is received
            if (m_end_state == ACE_IX) begin
                bit [addrMgrConst::W_SEC_ADDR - 1 : 0] sec_addr;
                sec_addr = addr;
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    sec_addr[addrMgrConst::W_SEC_ADDR - 1] = security;
                <%}%>
                m_addr_mgr.addr_evicted_from_agent(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1, sec_addr);
            end
            <% if(obj.COVER_ON) { %>
                  `ifndef FSYS_COVER_ON
                   <%if(obj.fnNativeInterface == "ACE") {%>
                   cov.ace_response(cmdtype,m_start_state,m_end_state,isShared,PassDirty);
                   <% } %>      
                  `endif 
              <%}%>
        endfunction : modify_cache_line

        function void modify_cache_line_for_snoop(axi_axaddr_t addr
            <%if(obj.wSecurityAttribute > 0){%>
                ,inout bit[<%=obj.wSecurityAttribute%>-1:0] security
            <%}%>);
            int                  m_tmp_q[$];
            int                  m_tmp_qA[$];

            if ($test$plusargs("snoop_bw_test")) begin
                return;
            end
            m_tmp_q = m_stt.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
            <%if(obj.wSecurityAttribute > 0) { %>
                && item.m_security == security
            <%}%>);
            if (m_tmp_q.size() == 0) begin
                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function modify_cache_line_for_snoop, cannot find address 0x%0x in stt", addr), UVM_NONE);
            end
            else if (m_tmp_q.size() > 1) begin
                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function modify_cl_4_snp found multiple entries in stt queues for the following address 0x%0x", addr), UVM_NONE);
            end
            else begin
                m_stt.delete(m_tmp_q[0]);
                <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                    ->e_cache_modify;
                <% } %>                                                
            end
            `uvm_info($sformatf("ACEBFM-DEBUG %s", get_full_name()), $sformatf("Changing cache line state for a snoop response for address 0x%0x security 0x%0x to end state %1p", addr, 
            <% if (obj.wSecurityAttribute > 0) { %>
                security,
            <% } else { %>
                0,
            <% } %>
            current_cache_state(addr
                <%if(obj.wSecurityAttribute > 0) { %>
                    ,security
                <% } %>
            )), UVM_LOW); 
        endfunction : modify_cache_line_for_snoop

        <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
            function void print_queues();
                `uvm_info("BFM INFO", $sformatf("Cache size %0d cache flush mode %0d pwrmgt_cache_flush %0d m_ort size %0d m_stt size %0d", m_cache.size(), cache_flush_mode_on, pwrmgt_cache_flush, m_ort.size(), m_stt.size()), UVM_NONE)
                foreach (m_cache[i]) begin
                    `uvm_info("CACHE", m_cache[i].sprint_pkt(), UVM_NONE);
                end
                foreach (m_ort[i]) begin
                    `uvm_info("ORT", $sformatf("%0p", m_ort[i]), UVM_NONE);
                end
                foreach (m_stt[i]) begin
                    `uvm_info("STT", $sformatf("%0p", m_stt[i]), UVM_NONE);
                end
            endfunction : print_queues

            task give_addr_for_ace_req_coh_write(output ace_command_types_enum_t cmdtype, output bit not_sending_addr, output axi_axaddr_t addr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    , output bit[<%=obj.wSecurityAttribute%>-1:0] security
                <% } %>);
                bit                                   done;
                bit                                   success = 0;
                int                                   count = 0;
                int                                   do_count = 0;
                aceState_t m_state_of_addr;
                ORT_struct_t                          m_tmp_var;
                // This bit is used to indicate the txn is for coherent or non-coherent traffic
                bit                                   is_coh;
                // This bit is only used in a pwrmgt cache flush when cache gets empty in the middle
                not_sending_addr = 0;

                if (cache_model_dbg_en == 1)
                    `uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write Number of lines in cache %0d cache_flush_mode_on:%0d pwrmgt_cache_flush:%0d prob_ace_coh_win_error:%0d", m_cache.size(), cache_flush_mode_on, pwrmgt_cache_flush, prob_ace_coh_win_error), UVM_LOW)

                if (!cache_flush_mode_on && !coh_write_seq_active) begin
                    if ($urandom_range(0,1000) < prob_cache_flush_mode_per_1k || pwrmgt_cache_flush == 1) begin
                        cache_flush_mode_on = 1;
                        count_till_end_of_coh_req = m_cache.size();
                    end
                    s_coh_noncoh.get();
                    if (end_of_sim) begin
                        s_coh_noncoh.put();
                    end
                    else begin
                        if (cache_model_dbg_en == 1)
                            `uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write Getting semaphore cache flush mode %0d cache size %0d", cache_flush_mode_on, m_cache.size()), UVM_LOW)
                        coh_write_seq_active = 1;
                    end
                end

                if (cache_model_dbg_en == 1)
                    `uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write After randomization cache_flush_mode_on:%0d", cache_flush_mode_on), UVM_LOW)
                
                // To slow down request processing
                //`uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write slow_down_req_processing do-while wait started total_outstanding_coh_writes:%0d", total_outstanding_coh_writes), UVM_LOW)
                done = 0;
                do begin
                    int m_tmp_qA[$];
                    m_tmp_qA = {};
                    m_tmp_qA = m_ort.find_first_index with (item.isRead == 0);
                    if (m_tmp_qA.size() < total_outstanding_coh_writes) begin
                        done = 1;
                    end
                    else begin
                        @e_ort_delete;
                    end
                end while (!done);
                
                //`uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write slow_down_req_processing do-while wait done total_outstanding_coh_writes:%0d", total_outstanding_coh_writes), UVM_LOW)

                done = 0;
                do begin
                    bit change_cache_size = 0;
                    if (cache_model_dbg_en == 1)
                        `uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write do-while loop start count:%0d do_count:%0d m_cache.size:%0d size_of_cache_limit:%0d", count, do_count, m_cache.size(), size_of_cache_limit), UVM_LOW)
               	//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_coh_write ort size before:%0d", m_ort.size()), UVM_LOW);
                while (m_ort.size == max_number_of_outstanding_txn) begin
                        @e_ort_delete;
                end
		//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_coh_write ort size after:%0d", m_ort.size()), UVM_LOW);

                    if ((m_cache.size() < size_of_cache_limit && !cache_flush_mode_on && count < 15) || m_cache.size() == 0) begin
                        process job;
                        if (cache_model_dbg_en == 1)
                            `uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write Waiting for cache add 0, cache size %0d count %0d limit %0d", m_cache.size(), count, size_of_cache_limit), UVM_LOW);
                        if (pwrmgt_cache_flush == 1 && m_cache.size() == 0) begin
                            not_sending_addr = 1;
                            return;
                        end
                        fork 
                            begin
                                @e_cache_add;
                            end
                            begin
                                job = process::self();
                                if (pwrmgt_cache_flush == 0) begin
                                    wait (pwrmgt_cache_flush == 1);
                                end
                                else begin
                                    job.suspend();
                                end
                            end
                        join_any
                        disable fork;
                        change_cache_size = 1;
                        // After 15 request fails, force a Update to happen
                        count++;
                    end
                    else begin //if ((m_cache.size() < size_of_cache_limit && !cache_flush_mode_on && count < 15) || m_cache.size() == 0) 
                        // Dont want to do a WRCLN when in cache flush mode. Only WRBK, WREVCT and EVCTs
                        /* int wt_ace_wrcln_tmp   = wt_ace_wrcln && !cache_flush_mode_on; */
                        int wt_ace_wrcln_tmp   = cache_flush_mode_on ? 0 : wt_ace_wrcln;
                        int wt_ace_wrbk_tmp    = wt_ace_wrbk;
                        int wt_ace_evct_tmp    = wt_ace_evct;
                        int wt_ace_wrevct_tmp  = wt_ace_wrevct;
                        //`uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write Pick a coherent request based on weights"), UVM_LOW);

                        if (pwrmgt_cache_flush == 1) begin 
                            wt_ace_wrcln_tmp = 0;
                        end
                        else if (wt_ace_wrcln_tmp > 0) begin
                            is_coh = calculate_is_coh(WRCLN);
                            success = calculate_start_state(WRCLN, m_state_of_addr, is_coh);
                            if (!success)
                                wt_ace_wrcln_tmp = 0;
                        end
                        
                        if (wt_ace_wrbk_tmp > 0) begin
                            is_coh = (pwrmgt_cache_flush == 1) ? 1 : calculate_is_coh(WRBK);
                            success = calculate_start_state(WRBK, m_state_of_addr, is_coh);
                            if (!success)
                                wt_ace_wrbk_tmp = 0;
                        end
                        
                        if (wt_ace_evct_tmp > 0) begin
                            is_coh = (pwrmgt_cache_flush == 1) ? 1 : calculate_is_coh(EVCT);
                            success = calculate_start_state(EVCT, m_state_of_addr, is_coh);
                            if (!success)
                                wt_ace_evct_tmp = 0;
                        end

                        if (wt_ace_wrevct_tmp > 0) begin
                            is_coh = (pwrmgt_cache_flush == 1) ? 1 : calculate_is_coh(WREVCT);
                            success = calculate_start_state(WREVCT, m_state_of_addr, is_coh);
                            if (!success)
                                wt_ace_wrevct_tmp = 0;
                        end
                        
                        //if (cache_model_dbg_en == 1)
                        //`uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write wt_ace_wrcln_tmp:%0d wt_ace_wrbk_tmp:%0d wt_ace_evct_tmp:%0d wt_ace_wrevct_tmp:%0d", wt_ace_wrcln_tmp, wt_ace_wrbk_tmp, wt_ace_evct_tmp, wt_ace_wrevct_tmp), UVM_LOW);
                        if (wt_ace_wrcln_tmp  == 0 &&
                            wt_ace_wrbk_tmp   == 0 &&
                            wt_ace_evct_tmp   == 0 &&
                            wt_ace_wrevct_tmp == 0
                        ) begin
                            process job;
                            if (pwrmgt_cache_flush == 1 && m_cache.size() == 0) begin
                                not_sending_addr = 1;
                                return;
                            end
                            <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                                fork 
                                    begin
                                        @e_cache_modify;
                                    end
                                    begin
                                        #(1us);
                                    end
                                    begin
                                        job = process::self();
                                        if (pwrmgt_cache_flush == 0) begin
                                            wait(pwrmgt_cache_flush == 1);
                                        end
                                        else begin
                                            job.suspend();
                                        end
                                    end
                                join_any
                                disable fork;
                            <% } %>                                                
                            if (pwrmgt_cache_flush == 1 && m_cache.size() == 0) begin
                                not_sending_addr = 1;
                                return;
                            end
                            if (cache_model_dbg_en == 1)
                            `uvm_info($sformatf("ace cache model%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_coh_write Hit continue count:%0d do_count:%0d", count, do_count), UVM_LOW);

                            continue;
                        end //if (wt_ace_wrcln_tmp  == 0 && wt_ace_wrbk_tmp   == 0 && wt_ace_evct_tmp   == 0 && wt_ace_wrevct_tmp == 0)
                        randcase
                            wt_ace_wrcln_tmp   : cmdtype = WRCLN;
                            wt_ace_wrbk_tmp    : cmdtype = WRBK;
                            wt_ace_evct_tmp    : cmdtype = EVCT;
                            wt_ace_wrevct_tmp  : cmdtype = WREVCT;
                        endcase

                        if (pwrmgt_cache_flush == 1)
                            is_coh = 1; //applies for ace cache flush sequence in sysco_tests
                        else 
                            is_coh = calculate_is_coh(cmdtype);
                        success = calculate_start_state(cmdtype, m_state_of_addr, is_coh);
                        if (cache_model_dbg_en == 1)
                                `uvm_info($sformatf("ace cache model%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_coh_write calculate_start_state returns success:%0d for cmdtype:%s, state:%s, is_coh:%b", success, cmdtype, m_state_of_addr.name(), is_coh), UVM_LOW);
                        if (change_cache_size) begin
                            size_of_cache_limit = $urandom_range(total_min_ace_cache_size,total_max_ace_cache_size);
                        end
                        if(success) begin
                        count = 0;
                        done  = 1;
                        end
                    end //if !((m_cache.size() < size_of_cache_limit && !cache_flush_mode_on && count < 15) || m_cache.size() == 0) 
                    do_count++;
                    if (cache_model_dbg_en == 1)
                    `uvm_info("ACE CACHE MODEL", $sformatf("fn:give_addr_for_ace_req_coh_write do-while loop end count:%0d do_count:%0d m_cache.size:%0d size_of_cache_limit:%0d", count, do_count, m_cache.size(), size_of_cache_limit), UVM_LOW)
                end while ((!done) && (do_count<1000));
                if (do_count == 1000) begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function give_addr_for_ace_req_coh_write unable to find addr even after 1000 iterations for Cmdtype %0s", cmdtype), UVM_NONE);
                end else begin 
                    if (cache_model_dbg_en == 1)
                        uvm_report_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_coh_write count:%0d do_count:%0d", count, do_count), UVM_LOW);
                end 
                if (!success) begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()),
                    $sformatf("TB Error: In function give_addr_for_ace_req_coh_write success cannot be 0 for command type %0s, state:%s, is_coh:%b", cmdtype, m_state_of_addr.name(), is_coh), UVM_NONE);
                end
                else begin //success=1
                    int m_tmp_qA[$];
                    int m_tmp_q[$];
                    m_tmp_q = {};
                    m_tmp_qA = {};
                    if(!$cast(tmp_aceState, m_state_of_addr))
                        `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
                    m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState);
                    foreach(m_tmp_qA[i]) begin
                        if(!is_coh) begin
                            //send memory update commands to non-coherent domain
                            if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 1) begin
                                if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                    <% if (obj.wSecurityAttribute > 0) { %>
                                        ,m_cache[m_tmp_qA[i]].m_security
                                    <% } %>
                                )) begin
                                    m_tmp_q.push_back(m_tmp_qA[i]);
                                end
                            end
                        end else if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 0) begin
                            if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    ,m_cache[m_tmp_qA[i]].m_security
                                <% } %>                                                
                            )) begin
                                m_tmp_q.push_back(m_tmp_qA[i]);
                            end
                        end
                    end
                    if (m_tmp_q.size() == 0) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error in give_addr_for_ace_req_coh_write: Cannot find state %0s in cache for cmdtype %0p. This error should not be seen", m_state_of_addr.name(), cmdtype), UVM_LOW);
                    end
                    else begin
                        m_tmp_q.shuffle();
                        addr = m_cache[m_tmp_q[0]].m_addr;
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            security = m_cache[m_tmp_q[0]].m_security;
                        <% } %>
                        if (cache_model_dbg_en == 1)
                            `uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Selected address 0x%0x ns:0x%0x", addr, security), UVM_LOW);
                    end
                end //success=1

                if (cache_model_dbg_en == 1)
                    `uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_coh_write cache flush mode %0d size of cache %0d limit %0d", cache_flush_mode_on, m_cache.size(), size_of_cache_limit), UVM_LOW);
                if (!cache_flush_mode_on && m_cache.size() <= size_of_cache_limit) begin
                    //`uvm_info("ACE CACHE MODEL%s", $sformatf("tsk:give_addr_for_ace_req_coh_write Release semaphore cache_flush_mode_on:0 && cache_size <= size_of_cache_limit"), UVM_LOW);
                    s_coh_noncoh.put();
                    coh_write_seq_active = 0;
                end
                if (cache_flush_mode_on) begin
                    count_till_end_of_coh_req--;
                    if (count_till_end_of_coh_req == 0) begin
                        if (pwrmgt_cache_flush && m_cache.size !== 0) begin
                            count_till_end_of_coh_req++;
                        end
                        else begin
                            cache_flush_mode_on = 0;
                            s_coh_noncoh.put();
                            coh_write_seq_active = 0;
                            //`uvm_info("ACE CACHE MODEL%s", $sformatf("tsk:give_addr_for_ace_req_coh_write Release semaphore cache_flush_mode_on:1 && count_till_end_of_coh_req:0"), UVM_LOW);
                        end
                    end
                end
                if (cache_model_dbg_en == 1)
                    `uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write cache_flush_mode_on:%0d count_till_end_of_coh_req:%0d coh_write_seq_active:%d end_of_sim:%0d", cache_flush_mode_on, count_till_end_of_coh_req, coh_write_seq_active, end_of_sim), UVM_LOW);
                m_tmp_var.m_cmdtype = cmdtype;
                m_tmp_var.m_addr    = addr;
                m_tmp_var.isUpdate  = 0;
                <% if (obj.wSecurityAttribute > 0) { %>
                    m_tmp_var.m_security = security;
                <% } %>
                if (m_tmp_var.m_cmdtype == WRNOSNP ||
                    m_tmp_var.m_cmdtype == WRUNQ   ||
                    m_tmp_var.m_cmdtype == WRLNUNQ ||
                    m_tmp_var.m_cmdtype == WREVCT  ||
                    m_tmp_var.m_cmdtype == WRBK    ||
                    m_tmp_var.m_cmdtype == EVCT    ||
                    m_tmp_var.m_cmdtype == WRCLN
                ) begin
                    m_tmp_var.isRead = 0;
                    if (m_tmp_var.m_cmdtype == WREVCT  ||
                        m_tmp_var.m_cmdtype == WRBK    ||
                        m_tmp_var.m_cmdtype == EVCT    ||
                        m_tmp_var.m_cmdtype == WRCLN
                    ) begin
                        m_tmp_var.isUpdate = 1;
                    end
                end
                else begin
                    m_tmp_var.isRead = 1;
                end

                if (!end_of_sim) begin
                    m_tmp_var.t_creation = $time;
                <% if(obj.testBench == "fsys") { %>
                if ($test$plusargs("random_gpra_nsx")) begin
                  //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                    m_tmp_var.m_security = addrMgrConst::get_addr_gprar_nsx(m_tmp_var.m_addr) ;
                end
                <% } %> 
                
                m_ort.push_back(m_tmp_var);
               // foreach (m_ort[i]) begin
               //     `uvm_info("ORT_after_push_back_req_coh_write", $sformatf("idx:%0d %0p", i, m_ort[i]), UVM_LOW);
               // end

                    if (cache_model_dbg_en == 1)
                	`uvm_info("ACE CACHE MODEL", $sformatf("tsk:give_addr_for_ace_req_coh_write currstate:%0p added txn to ORT %0p", tmp_aceState, m_tmp_var), UVM_LOW);
                    <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                        ->e_cache_modify;
                    <% } %>                                                
                end
                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || (obj.Block === 'mem' && obj.is_master === 1)) { %>
                  s_coh_noncoh.put();
                <%}%>
            endtask : give_addr_for_ace_req_coh_write
        <%}%>

        task give_addr_for_ace_req_noncoh_write(int id, ref ace_command_types_enum_t cmdtype, output axi_axaddr_t addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                , output bit[<%=obj.wSecurityAttribute%>-1:0] security
            <% } %>
            ,output bit is_coh
            , input bit use_addr_from_test = 0, input axi_axaddr_t m_ace_wr_addr_from_test = 0
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                , input bit[<%=obj.wSecurityAttribute%>-1:0] m_ace_wr_security_from_test = 0 
            <% } %>
                ,output bit addr_gen_failure);
            bit                                   done;
            bit                                   success            = 0;
            aceState_t m_state_of_addr;
            ORT_struct_t                          m_tmp_var;
            int                                   m_tmp_q[$];
            int                                   random_max_write_size = 0;
            int                                   count;
            int                                   do_count=0;
            int                                   z_count =0;
            int                                   z2_count =0;
            bit tmp_security;
            bit [addrMgrConst::W_SEC_ADDR - 1: 0] sec_addr;
            int pick_itr;
            int pick_itr_q[$];
            int                         num_coh_addr_in_ort[$];
            int                         num_noncoh_addr_in_ort[$];


            // Trying to limit number of NONCoh Writes. If this code is not present, all writes get generated at time 0
            random_max_write_size = $urandom_range(5,25);
            done = 0;
            if(cmdtype inside {WRBK,WRCLN,WREVCT} ) begin
               is_coh = 0;
            end else begin
               is_coh = calculate_is_coh(cmdtype);
            end
            <% if( (obj.fnNativeInterface == "ACELITE-E") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5") ||(obj.Block === 'mem' && obj.is_master === 1)  || (obj.testBench == "emu")) { %>    
                success = 1;
                m_state_of_addr = ACE_IX;
            <% }else { %>    
                //`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write cmdtype:%0s random_max_write:%0d", cmdtype, random_max_write_size), UVM_LOW);
                do begin
                    m_tmp_q = {};
                    m_tmp_q = m_ort.find_index with (item.isRead == 0);
                	//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write 1st do-while tmpq.size:%0d", m_tmp_q.size()), UVM_LOW);
                    if (m_tmp_q.size() < random_max_write_size || $test$plusargs("perf_test") || end_of_sim == 1) begin
                        done = 1;
                    end
                    else begin
                        @e_ort_delete;
                		//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write 1st do-while ort delete entry"), UVM_LOW);
                    end
                end while (!done);
				//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write 1st do-while end"), UVM_LOW);
                s_coh_noncoh.get();
                done = 0;
				//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write 2nd do-while begin"), UVM_LOW);
                do begin
                    int m_tmp_qA[$];
                    m_tmp_qA = {};
                    m_tmp_qA = m_ort.find_first_index with (
                        item.m_cmdtype == WREVCT ||
                        item.m_cmdtype == EVCT   ||
                        item.m_cmdtype == WRBK   ||
                        item.m_cmdtype == WRCLN
                    );
                	//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write 2nd do-while tmpqA.size:%0d", m_tmp_qA.size()), UVM_LOW);
                    if (m_tmp_qA.size() == 0) begin
                        done = 1;
                    end
                    else begin
                        @e_ort_delete;
                		//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write 2nd do-while ort delete entry"), UVM_LOW);
                    end
                end while (!done);
				//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write 2nd do-while end"), UVM_LOW);
                
                <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){ %>
                while ((m_ort.size == max_number_of_outstanding_txn) ) begin
                       @e_ort_delete;
                end
		//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write ort size after:%0d", m_ort.size()), UVM_LOW);
                <% } %>      
                success = calculate_start_state(cmdtype, m_state_of_addr, is_coh);
            <% } %>      
            if (!success) begin
                $stacktrace();
                `uvm_error(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_req_noncoh_write success=0 for CmdType:%0s isCoh:%0d", cmdtype, is_coh));
            end else begin 
		//`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_noncoh_write id:%0d CmdType:%0s isCoh:%0b state_of_addr:%0p", id, cmdtype, is_coh, m_state_of_addr), UVM_LOW);
            end
  
                       
            if (m_state_of_addr == ACE_IX) begin: _cache_state_IX_
                bit non_coh_addr;
                bit done = 0;
                non_coh_addr = !is_coh;
                do begin
                    bit [63:0] m_ort_addr_q[$];
                    m_ort_addr_q = {};
                    <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                        foreach (m_ort[i]) begin
                            m_ort_addr_q.push_back(m_ort[i].m_addr);
                        end
                        foreach (m_stt[i]) begin
                            m_ort_addr_q.push_back(m_stt[i].m_addr);
                        end
                    <% } %>
                    if (non_coh_addr) begin: _noncoh_addr_
                        int  gen_addr_to_dmi = <%=obj.DiiInfo.length%> < 2 ? 1 : $urandom_range(0,99) < prob_of_dmi_dii_addr ? 1 : 0;
                        if ((addrMgrConst::aiu_connected_dii_ids[funitid].ConnectedfUnitIds.size() == 0) ||
                            ((addrMgrConst::aiu_connected_dii_ids[funitid].ConnectedfUnitIds.size() == 1) && (addrMgrConst::aiu_connected_dii_ids[funitid].ConnectedfUnitIds[0] == addrMgrConst::funit_ids[addrMgrConst::diiIds[addrMgrConst::get_sys_dii_idx()]])))  begin
                            gen_addr_to_dmi = 1;//force DMI target as no DII is connected for this agent   
                        end  
                        if (cmdtype inside {ATMLD,ATMSWAP,ATMSTR,ATMCOMPARE}) begin
                            //DII is not able to handle atomic txn. Only send to dmi
                            gen_addr_to_dmi = 1;
                        end
                        if($test$plusargs("use_user_addrq") && (user_addrq[addrMgrConst::NONCOH].size()>0)) begin: _use_user_addrq_
                            //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_noncoh_write user_addrq.NONCOH.size:%0d", user_addrq[addrMgrConst::NONCOH].size()), UVM_LOW);
                            if ($test$plusargs("use_user_write_read_addrq") || $test$plusargs("use_user_rw_addrq")) begin
                                if(user_write_addrq_idx[addrMgrConst::NONCOH] == -1) begin
                                    bit brek;
                                    count = 0;
                                    do begin
                                        count++;
                                        pick_itr = $urandom_range(user_write_addrq[addrMgrConst::NONCOH].size()-1);
                                        sec_addr = user_write_addrq[addrMgrConst::NONCOH][pick_itr];
                                        sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                        if(cmdtype inside {ATMLD,ATMSWAP,ATMSTR,ATMCOMPARE} && addrMgrConst::is_dii_addr(sec_addr)==1) begin
                                            do begin 
                                                pick_itr = $urandom_range(user_write_addrq[addrMgrConst::NONCOH].size()-1);
                                                sec_addr = user_write_addrq[addrMgrConst::NONCOH][pick_itr];
                                                sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                            // `uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_noncoh_write user_write_addrq.NONCOH returned DII addr for atomic cmdtype:%0s isCoh:%0d)", cmdtype, is_coh), UVM_LOW);
                                            end while(addrMgrConst::is_dii_addr(sec_addr));
                                        //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_noncoh_write user_write_addrq.NONCOH returned DMI addr for atomic cmdtype:%0s isCoh:%0d)", cmdtype, is_coh), UVM_LOW);
                                        end
                                        if (current_cache_state(sec_addr
                                                <% if (obj.wSecurityAttribute > 0) { %>
                                                ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                <% } %>
                                                ) == ACE_IX) begin
                                                break;
                                        end
                                        <% if ( obj.initiatorGroups.length >= 1) { %>
                                            addr     = sec_addr;
                                            if(!$test$plusargs("check_unmapped_add") && addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected)) begin
                                                brek = 0; // Force random picked address into user_write_addrq to be connected to the initiator
                                            end
                                        <% } %>
                                    end while((!brek) && (count < 1000));
                                end else begin
                                    int cnt = 0;
                                    //do begin 
                                        //cnt++;
                                        if (cmdtype inside {ATMLD,ATMSWAP,ATMSTR,ATMCOMPARE}) begin: _atomics_
                                            do begin 
                                                sec_addr = user_write_addrq[addrMgrConst::NONCOH][user_write_addrq_idx[addrMgrConst::NONCOH]];
                                                sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                                if (!$test$plusargs("force_unique_addr")) user_write_addrq_idx[addrMgrConst::NONCOH] = user_write_addrq_idx[addrMgrConst::NONCOH] + 1;
                                                if(user_write_addrq_idx[addrMgrConst::NONCOH] >= user_write_addrq[addrMgrConst::NONCOH].size() || (use_loop_addr>0 && user_write_addrq_idx[addrMgrConst::NONCOH] >= use_loop_addr)) begin
                                                    user_write_addrq_idx[addrMgrConst::NONCOH] = use_loop_addr_offset;
                                                    use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                                    use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                                end
                                            end while(addrMgrConst::is_dii_addr(sec_addr));
                                        end : _atomics_
                                        else begin: _not_atomics_ 

                                            <% if(obj.testBench == "fsys") { %>
                                            if($test$plusargs("individual_initiator_addrq")) begin
                                                sec_addr = user_write_addrq[addrMgrConst::NONCOH][((<%=obj.nCHIs%>*num_trans_per_chi) + (<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn - obj.nCHIs%>)*num_trans_per_ioaiu) + user_write_addrq_idx[addrMgrConst::NONCOH]];
                                            end else begin
                                                sec_addr = user_write_addrq[addrMgrConst::NONCOH][user_write_addrq_idx[addrMgrConst::NONCOH]];
                                            end
                                            <% } else { %>
                                            sec_addr = user_write_addrq[addrMgrConst::NONCOH][user_write_addrq_idx[addrMgrConst::NONCOH]];
                                            <% } %>
                                            sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);

                                            if (!$test$plusargs("force_unique_addr")) user_write_addrq_idx[addrMgrConst::NONCOH] = user_write_addrq_idx[addrMgrConst::NONCOH] + 1;
                                            if(user_write_addrq_idx[addrMgrConst::NONCOH] >= user_write_addrq[addrMgrConst::NONCOH].size() || (use_loop_addr>0 && user_write_addrq_idx[addrMgrConst::NONCOH] >= use_loop_addr)) begin
                                                user_write_addrq_idx[addrMgrConst::NONCOH] = use_loop_addr_offset;
                                                use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                                use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                            end
                                        end: _not_atomics_
                                    //end while ((current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> , sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) != ACE_IX) && (cnt <= user_write_addrq[addrMgrConst::NONCOH].size()));

                                end

                            end else begin
                                if(user_addrq_idx[addrMgrConst::NONCOH] == -1) begin
                                    bit brek;
                                    count = 0;
                                    do begin
                                        count++;
                                        pick_itr = $urandom_range(user_addrq[addrMgrConst::NONCOH].size()-1);
                                        sec_addr = user_addrq[addrMgrConst::NONCOH][pick_itr];
                                        sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                        if(cmdtype inside {ATMLD,ATMSWAP,ATMSTR,ATMCOMPARE} && addrMgrConst::is_dii_addr(sec_addr)==1) begin
                                            do begin 
                                                pick_itr = $urandom_range(user_addrq[addrMgrConst::NONCOH].size()-1);
                                                sec_addr = user_addrq[addrMgrConst::NONCOH][pick_itr];
                                                sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                            // `uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_noncoh_write user_addrq.NONCOH returned DII addr for atomic cmdtype:%0s isCoh:%0d)", cmdtype, is_coh), UVM_LOW);
                                            end while(addrMgrConst::is_dii_addr(sec_addr));
                                        //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_noncoh_write user_addrq.NONCOH returned DMI addr for atomic cmdtype:%0s isCoh:%0d)", cmdtype, is_coh), UVM_LOW);
                                        end
                                        if (current_cache_state(sec_addr
                                                <% if (obj.wSecurityAttribute > 0) { %>
                                                ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                <% } %>
                                                ) == ACE_IX) begin
                                                break;
                                        end
                                        <% if ( obj.initiatorGroups.length >= 1) { %>
                                            addr     = sec_addr;
                                            if(!$test$plusargs("check_unmapped_add") && addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected)) begin
                                                brek = 0; // Force random picked address into user_addrq to be connected to the initiator
                                            end
                                        <% } %>
                                    end while((!brek) && (count < 1000));
                                end else begin
                                    int cnt = 0;
                                    //do begin 
                                        //cnt++;
                                        if (cmdtype inside {ATMLD,ATMSWAP,ATMSTR,ATMCOMPARE}) begin: _atomics_
                                            do begin 
                                                sec_addr = user_addrq[addrMgrConst::NONCOH][user_addrq_idx[addrMgrConst::NONCOH]];
                                                sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                                if (!$test$plusargs("force_unique_addr")) user_addrq_idx[addrMgrConst::NONCOH] = user_addrq_idx[addrMgrConst::NONCOH] + 1;
                                                if(user_addrq_idx[addrMgrConst::NONCOH] >= user_addrq[addrMgrConst::NONCOH].size() || (use_loop_addr>0 && user_addrq_idx[addrMgrConst::NONCOH] >= use_loop_addr)) begin
                                                    user_addrq_idx[addrMgrConst::NONCOH] = use_loop_addr_offset;
                                                    use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                                    use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                                end
                                            end while(addrMgrConst::is_dii_addr(sec_addr));
                                        end : _atomics_
                                        else begin: _not_atomics_ 
                                            <% if(obj.testBench == "fsys") { %>
                                            if($test$plusargs("individual_initiator_addrq")) begin
                                                sec_addr = user_addrq[addrMgrConst::NONCOH][((<%=obj.nCHIs%>*num_trans_per_chi) + (<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn%>)*num_trans_per_ioaiu) + user_addrq_idx[addrMgrConst::NONCOH]];
                                            end else begin
                                                sec_addr = user_addrq[addrMgrConst::NONCOH][user_addrq_idx[addrMgrConst::NONCOH]];
                                            end
                                            <% } else { %>
                                            sec_addr = user_addrq[addrMgrConst::NONCOH][user_addrq_idx[addrMgrConst::NONCOH]];
                                            <% } %>
                                            sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);

                                            if (!$test$plusargs("force_unique_addr")) user_addrq_idx[addrMgrConst::NONCOH] = user_addrq_idx[addrMgrConst::NONCOH] + 1;
                                            if(user_addrq_idx[addrMgrConst::NONCOH] >= user_addrq[addrMgrConst::NONCOH].size() || (use_loop_addr>0 && user_addrq_idx[addrMgrConst::NONCOH] >= use_loop_addr)) begin
                                                user_addrq_idx[addrMgrConst::NONCOH] = use_loop_addr_offset;
                                                use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                                use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                            end
                                        end: _not_atomics_
                                    //end while ((current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> , sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) != ACE_IX) && (cnt <= user_addrq[addrMgrConst::NONCOH].size()));

                                end
                            end
                            m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, funitid); 
                        end: _use_user_addrq_
                        else if ($urandom_range(1,99) < prob_of_new_addr) begin
                            bit brek;
                            count = 0;
                            do begin
                                count++;
                                <% if(obj.testBench == "io_aiu" || obj.testBench == "fsys") { %>
                                    if(gen_addr_to_dmi) begin
                                        sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);
                                    end else begin
                                        sec_addr = m_addr_mgr.gen_iocoh_addr(funitid, 1, 1, core_id);
                                    end 
                                <% } else { %>
                                    sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);
                                <% } %>
                                if (current_cache_state(sec_addr
                                    <% if (obj.wSecurityAttribute > 0) { %>
                                    ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                    <% } %>
                                ) == ACE_IX) begin
                                    brek = 1;
                                end
                            end while((!brek) && (count < 1000));
                            if(!brek) begin
                                count = 0;
                                do begin
                                    count++;
                                    if(gen_addr_to_dmi) begin
                                        sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                                    end else begin
                                        sec_addr = m_addr_mgr.get_iocoh_addr(funitid, 1, core_id);
                                    end
                                    if (current_cache_state(sec_addr
                                    <% if (obj.wSecurityAttribute > 0) { %>
                                    ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                    <% } %>
                                    ) == ACE_IX) begin
                                        break;
                                    end
                                  end while(count < 1000);
                                if(count == 1000) begin
                                    $stacktrace();
                                    `uvm_error(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_noncoh_write address manager can't return any address which has cache state IX cmdtype:%0s isCoh:%0d prob_of_new_addr > 1..99)", cmdtype, is_coh));
                                end
                            end
                            m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, funitid);
                        end else begin
                            bit brek;
                            count = 0;
                            do begin
                                count++;
                                if(gen_addr_to_dmi) begin
                                    sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                                end else begin
                                    sec_addr = m_addr_mgr.get_iocoh_addr(funitid, 1, core_id);
                                end
                                if (current_cache_state(sec_addr
                                    <% if (obj.wSecurityAttribute > 0) { %>
                                        ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                    <% } %>
                                    ) == ACE_IX) begin
                                    brek = 1;
                                end
                            end while((!brek) && (count < 1000));
                            if(!brek) begin
                                count = 0;
                                do begin
                                    count++;
                                    if(gen_addr_to_dmi) begin
                                        sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);
                                    end else begin
                                        sec_addr = m_addr_mgr.gen_iocoh_addr(funitid, 1, 1, core_id);
                                    end
                                    if (current_cache_state(sec_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                        <% } %>
                                        ) == ACE_IX) begin
                                        break;
                                    end
                                end while(count < 1000);
                                if(count == 1000) begin
                                    $stacktrace();
                                    `uvm_error(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_noncoh_write address manager can't return any address which has cache state IX cmdtype:%0s isCoh:%0d prob_of_new_addr < 1..99)", cmdtype, is_coh));
                                end
                            end
                        end
                        tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                        addr     = sec_addr;
                        m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, funitid);
                    end: _noncoh_addr_
                    else begin: _coh_addr_

                        if($test$plusargs("use_user_addrq")  && (user_addrq[addrMgrConst::COH].size()>0)) begin: _use_user_addrq_coh_addr_

                            if($test$plusargs("use_user_write_read_addrq") || $test$plusargs("use_user_rw_addrq")) begin : _some_perf_plusargs_

                                if(user_write_addrq_idx[addrMgrConst::COH] == -1) begin
                                    bit brek;
                                    count = 0;
                                    do begin
                                        count++;
                                        pick_itr = $urandom_range(user_write_addrq[addrMgrConst::COH].size()-1);
                                        sec_addr = user_write_addrq[addrMgrConst::COH][pick_itr];
                                        sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                        if (current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) == ACE_IX) begin
                                            brek = 1;
                                        end
                                        <% if ( obj.initiatorGroups.length >= 1) { %>
                                            addr     = sec_addr;
                                            if(!$test$plusargs("check_unmapped_add") && addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected)) begin
                                                brek = 0; // Force random picked address into user_write_addrq to be connected to the initiator
                                            end
                                        <% } %>
                                    end while((!brek) && (count < 1000));
                                end
                                else begin
                                    do begin 
                                        z_count++;
                                        <% if(obj.testBench == "fsys") { %>
                                        if($test$plusargs("individual_initiator_addrq")) begin
                                            sec_addr = user_write_addrq[addrMgrConst::COH][((<%=obj.nCHIs%>*num_trans_per_chi) + (<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn%>)*num_trans_per_ioaiu) + user_write_addrq_idx[addrMgrConst::COH]];
                                        end else begin
                                            sec_addr = user_write_addrq[addrMgrConst::COH][user_write_addrq_idx[addrMgrConst::COH]];
                                        end
                                        <% } else { %>
                                        sec_addr = user_write_addrq[addrMgrConst::COH][user_write_addrq_idx[addrMgrConst::COH]];
                                        <% } %>
                                        sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                   
                                        if (!$test$plusargs("force_unique_addr")) user_write_addrq_idx[addrMgrConst::COH] = user_write_addrq_idx[addrMgrConst::COH] + 1;
                                        if(user_write_addrq_idx[addrMgrConst::COH] >= user_write_addrq[addrMgrConst::COH].size() || (use_loop_addr>0 && user_write_addrq_idx[addrMgrConst::COH] >= use_loop_addr)) begin
                                            user_write_addrq_idx[addrMgrConst::COH] = use_loop_addr_offset;
                                            use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                            use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                        end
                                        //`uvm_info(get_full_name(), $sformatf("DBG: fn:give_addr_for_ace_noncoh_write finding user_write_addrq[addrMgrConst::COH] IX addr cnt:%0d", cnt), UVM_LOW);
                                    end while ((current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> , sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) != ACE_IX) && (z_count <= user_write_addrq[addrMgrConst::COH].size()));
                                    if (current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> , sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) != ACE_IX) begin 
                                        //`uvm_info(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_noncoh_write no IX address found in user_write_addrq[addrMgrConst::COH] cmdtype:%0s isCoh:%0d", cmdtype, is_coh), UVM_LOW);
                                        addr_gen_failure = 1;
                                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || (obj.Block === 'mem' && obj.is_master === 1)) { %>
                                        s_coh_noncoh.put();
                                    <%}%>
                                        return;
                                    end
                                end

                            end: _some_perf_plusargs_
                            else begin
                                `uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_noncoh_write id:%0d user_addrq.COH.size:%0d user_addrq_idx[addrMgrConst::COH]:%0d", id, user_addrq[addrMgrConst::COH].size(), user_addrq_idx[addrMgrConst::COH]), UVM_LOW);
                                if(user_addrq_idx[addrMgrConst::COH] == -1) begin
                                    bit brek;
                                    pick_itr_q = {};
                                    do begin
                                        brek = 0;
                                        assert(std::randomize(pick_itr) with {(!(pick_itr inside {pick_itr_q})) && pick_itr inside {[0:user_addrq[addrMgrConst::COH].size()-1]};})
                                        else 
                                          `uvm_error("ACE CACHE MODEL", "Failure to randomize pick_itr");
                                        pick_itr_q.push_back(pick_itr);
                                        sec_addr = user_addrq[addrMgrConst::COH][pick_itr];
                                        sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                        if (current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) == ACE_IX && check_if_addr_is_ok_to_send(cmdtype, sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>)) begin
                                            brek = 1;
                                        end
                                        <% if ( obj.initiatorGroups.length >= 1) { %>
                                            addr     = sec_addr;
                                            if(!$test$plusargs("check_unmapped_add") && addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected)) begin
                                                brek = 0; // Force random picked address into user_addrq to be connected to the initiator
                                            end
                                        <% } %>
                                        //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_noncoh_write pick_itr_q %0p and brek:%0d",pick_itr_q,brek), UVM_LOW);
                                    end while((!brek) && (pick_itr_q.size() < user_addrq[addrMgrConst::COH].size()));
                                      
                                    if(pick_itr_q.size() == user_addrq[addrMgrConst::COH].size() && !brek) begin
                                        addr_gen_failure = 1;
                                      <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                                        s_coh_noncoh.put();
                                    <%}%>
                                        return;
                                    end
                                    
                                end
                                else begin
                                    bit brek;
                                    do begin 
                                        brek=0;
                                        z2_count++;
                                        //`uvm_info(get_full_name(), $sformatf("DBG: fn:give_addr_for_ace_noncoh_write id:%0d finding user_addrq[addrMgrConst::COH] IX addr z2_count:%0d idx:%0d", id, z2_count, user_addrq_idx[addrMgrConst::COH]), UVM_LOW);
                                        <% if(obj.testBench == "fsys") { %>
                                        if($test$plusargs("individual_initiator_addrq")) begin
                                            sec_addr = user_addrq[addrMgrConst::COH][(<%=obj.nCHIs%>*num_trans_per_chi) + ((<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn%>)*num_trans_per_ioaiu) + user_addrq_idx[addrMgrConst::COH]];
                                        end else begin
                                            sec_addr = user_addrq[addrMgrConst::COH][user_addrq_idx[addrMgrConst::COH]];
                                        end
                                        <% } else { %>
                                        sec_addr = user_addrq[addrMgrConst::COH][user_addrq_idx[addrMgrConst::COH]];
                                        <% } %>
                                        sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);

                                        if (!$test$plusargs("force_unique_addr")) user_addrq_idx[addrMgrConst::COH] = user_addrq_idx[addrMgrConst::COH] + 1;
                                        if(user_addrq_idx[addrMgrConst::COH] >= user_addrq[addrMgrConst::COH].size() || (use_loop_addr>0 && user_addrq_idx[addrMgrConst::COH] >= use_loop_addr)) begin
                                            user_addrq_idx[addrMgrConst::COH] = use_loop_addr_offset;
                                            use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                            use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                        end
                                        if ((current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) == ACE_IX) && 
                                            check_if_addr_is_ok_to_send(cmdtype, sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>)) 
                                        begin
                                            brek = 1;
                                        end
                                    end while ((brek==0) && (z2_count < user_addrq[addrMgrConst::COH].size()));
                                    if (brek == 0) begin 
                                        //`uvm_info(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_noncoh_write no IX address found in user_addrq[addrMgrConst::COH] cmdtype:%0s isCoh:%0d", cmdtype, is_coh), UVM_LOW);
                                        addr_gen_failure = 1;
                                    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || (obj.Block === 'mem' && obj.is_master === 1)) { %>
                                        s_coh_noncoh.put();
                                    <%}%>
                                        return;
                                    end
                                end
                            end
                            m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, funitid); 
                        end: _use_user_addrq_coh_addr_
                        else if ($urandom_range(1,99) < prob_of_new_addr) begin: _prob_new_addr_
                                bit brek;
                                count = 0;
                                do begin
                                    count++;
                                    sec_addr = this.gen_new_cacheline(funitid, 1, core_id);
                                    if (current_cache_state(sec_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                        ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                        <% } %>
                                    ) == ACE_IX) begin
                                        brek = 1;
                                    end
                                end while((!brek) && (count < 1000));
                                    if(!brek) begin
                                        count = 0;
                                        do begin
                                            count++;
                                            sec_addr = m_addr_mgr.get_coh_addr(funitid, 1, 0, core_id);
                                            if (current_cache_state(sec_addr
                                                <% if (obj.wSecurityAttribute > 0) { %>
                                                ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                <% } %>
                                                ) == ACE_IX) begin
                                                break;
                                            end
                                        end while(count < 1000);
                                        if(count == 1000) begin
                                            $stacktrace();
                                            `uvm_error(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_noncoh_write address manager can't return any address which has cache state IX cmdtype:%0s isCoh:%0d prob_of_new_addr > 1..99)", cmdtype, is_coh));
                                        end
                                    end
                                end : _prob_new_addr_
                                else begin
                                    bit brek;
                                    count = 0;
                                    do begin
                                        count++;
                                        sec_addr = m_addr_mgr.get_coh_addr(funitid, 1, 0, core_id);
                                        if (current_cache_state(sec_addr
                                            <% if (obj.wSecurityAttribute > 0) { %>
                                            ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                            <% } %>
                                        ) == ACE_IX) begin
                                            brek = 1;
                                        end
                                    end while((!brek) && (count < 1000));
                                    if(!brek) begin
                                        count = 0;
                                        do begin
                                            count++;
                                            sec_addr = this.gen_new_cacheline(funitid, 1, core_id);
                                            if (current_cache_state(sec_addr
                                                <% if (obj.wSecurityAttribute > 0) { %>
                                                ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                <% } %>
                                                ) == ACE_IX) begin
                                                break;
                                            end
                                        end while(count < 1000);
                                        if(count == 1000) begin
                                            $stacktrace();
                                            `uvm_error(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_noncoh_write address manager can't return any address which has cache state IX cmdtype:%0s isCoh:%0d prob_of_new_addr < 1..99)", cmdtype, is_coh));
                                        end
                                    end
                                end
                                tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                                addr     = sec_addr;
                            end: _coh_addr_
                             <%if(obj.Block == "io_aiu") { %>
                            if ($test$plusargs("all_gpra_secure") || $test$plusargs("error_test")) begin 
                            security = !addrMgrConst::get_addr_gprar_nsx(sec_addr) ;
                            end
                            <%}%>
                         <% if (obj.wSecurityAttribute > 0) { %>
                             <% if(obj.testBench == "fsys") { %>
                                if ($test$plusargs("random_gpra_nsx")) begin
                                //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                                security = addrMgrConst::get_addr_gprar_nsx(sec_addr) ;
                                end else begin
                                security = tmp_security;
                                end
                             <%}else{%>
                                security = tmp_security;
                             <% } %>                                             
                            
                        <% } %>                                                
                        if (check_if_addr_is_ok_to_send(cmdtype, addr
                                <%if(obj.wSecurityAttribute > 0) { %>                                             
                                    ,security
                                <%}%>)) begin
                            done = 1;
                        end
			do_count++; //avoid eternal loop				
                        if (do_count >10000) break;
		end while ((!done) || addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected));//#TRY_TO_GEx_RD_ADDR
        //`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("do_count:%0d Cmdtype %0s addr:0x%0h", do_count, cmdtype, addr), UVM_LOW);
                    if (do_count > 10000) begin
                        $stacktrace();
                        `uvm_error(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_req_noncoh_write unable to find addr even after 10000 iterations for Cmdtype %0s isCoh:%0d", cmdtype, is_coh));
                    end    
                    if (current_cache_state(addr <% if (obj.wSecurityAttribute > 0) { %>,security<% } %>) !== ACE_IX) begin
                            //if (!$test$plusargs("use_seq_user_addrq")) begin
                              $stacktrace();
                              `uvm_error(get_full_name(), $sformatf("TB Error: function:give_addr_for_ace_req_noncoh_write address 0x%0x returned by address manager is already in cache in state %p we need IX for cmdtype:%0s isCoh:%0d", addr, current_cache_state(addr <% if (obj.wSecurityAttribute > 0) { %> ,security <% } %>), cmdtype, is_coh));
                           //end
                    end
                end: _cache_state_IX_
                else begin: _cache_state_vld_
                    int m_tmp_q[$];
                    int m_tmp_qA[$];
                    m_tmp_q = {};
                    m_tmp_qA = {};
                    if(!$cast(tmp_aceState, m_state_of_addr))
                        `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
                    if((cmdtype inside {WRBK,WRCLN} && $test$plusargs("force_wb_wc_noncoh")) || (cmdtype ==WREVCT && $test$plusargs("force_we_noncoh"))) 
                    begin
                        m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState && item.m_non_coherent_addr==1);
                    end else begin
                    m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState);
                    end
                    foreach(m_tmp_qA[i]) begin
                        if (!is_coh) begin
                            if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 1) begin
                                if(cmdtype == RDNOSNP ||
                                cmdtype == WRNOSNP
                                ) begin
                                    if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,m_cache[m_tmp_qA[i]].m_security
                                        <% } %>
                                        )) begin
                                        m_tmp_q.push_back(m_tmp_qA[i]);
                                    end
                                end else begin
                                    if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,m_cache[m_tmp_qA[i]].m_security
                                        <% } %>
                                        )) begin
                                        m_tmp_q.push_back(m_tmp_qA[i]);
                                    end
                                end
                            end
                        end
                        else if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 0) begin
                            if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    ,m_cache[m_tmp_qA[i]].m_security
                                <% } %>                                                
                            )) begin
                                m_tmp_q.push_back(m_tmp_qA[i]);
                            end
                        end
                    end
                    if (m_tmp_q.size() == 0) begin
                        $stacktrace();uvm_report_warning($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error in give_addr_for_ace_req_noncoh_write: Cannot find state %0s in cache for cmdtype %0p. This error should not be seen", m_state_of_addr.name(), cmdtype), UVM_NONE);
                        addr_gen_failure = 1;
                        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || (obj.Block === 'mem' && obj.is_master === 1)) { %>
                         s_coh_noncoh.put();
                        <%}%>
                        return;
                    end
                    else begin
                        m_tmp_q.shuffle();
                        addr = m_cache[m_tmp_q[0]].m_addr;
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            security = m_cache[m_tmp_q[0]].m_security;
                        <% } %>                                                
                        //uvm_report_info("give_addr_for_ace_req_noncoh_write", $sformatf("tsk:give_addr_for_ace_req_noncoh_write selected address 0x%0x", addr), UVM_LOW);
                    end
            end: _cache_state_vld_
            if (use_addr_from_test) begin
                addr = m_ace_wr_addr_from_test;
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    security = m_ace_wr_security_from_test;
                <% } %>                                                
            end
            <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                s_coh_noncoh.put();
            <% } %>

            m_tmp_var.t_creation = $time;
            m_tmp_var.m_cmdtype = cmdtype;
            m_tmp_var.isUpdate  = 0;
            m_tmp_var.isRead    = 0;
            m_tmp_var.isNonCoh  = !is_coh;
            if((cmdtype inside {WRBK,WRCLN} && $test$plusargs("force_wb_wc_noncoh")) || (cmdtype ==WREVCT && $test$plusargs("force_we_noncoh"))) begin
               m_tmp_var.isUpdate  = 1;
            end else begin 
               m_tmp_var.isUpdate  = 0;
            end
            m_tmp_var.m_addr    = addr;
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_tmp_var.m_security = security;
            <% } %> 

            <% if(obj.testBench == "fsys") { %>
            if ($test$plusargs("random_gpra_nsx")) begin
              //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                m_tmp_var.m_security = addrMgrConst::get_addr_gprar_nsx(m_tmp_var.m_addr) ;
            end
            <% } %>
            <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                if (!pwrmgt_cache_flush) begin
            <%}%>   
            m_ort.push_back(m_tmp_var);
            //foreach (m_ort[i]) begin
            //    `uvm_info("ORT_after_push_back_noncoh_write", $sformatf("idx:%0d %0p", i, m_ort[i]), UVM_LOW);
            //end

            //`uvm_info(get_full_name(), $sformatf("tsk:give_addr_for_ace_req_noncoh_write from currstate:%0p added txn to ORT %0p", current_cache_state(addr
            //                                        <% if (obj.wSecurityAttribute > 0) { %>
            //                                        , addr[addrMgrConst::W_SEC_ADDR - 1]
            //                                        <% } %>
            //                                        ), m_tmp_var), UVM_LOW);
            <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                end
                ->e_cache_modify;
            <%}%>
        endtask : give_addr_for_ace_req_noncoh_write

<%if (obj.testBench == "fsys") {%>
        function bit [addrMgrConst::W_SEC_ADDR -1:0] gen_sel_targ_addr_from_unit_attr(
         string unit_type="DII", /* "DII" OR "DMI" */
         int unit_id=0, /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
         int index=0, /*For multiple mem region configured for any DII or DMI, select one of them.*/
         bit nc=1);
            return m_addr_mgr.gen_sel_targ_addr_from_unit_attr(unit_type,unit_id,index,nc);
        endfunction
<% } %>

        function bit give_addr_for_ace_req_read(int id, ref ace_command_types_enum_t cmdtype, output axi_axaddr_t addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                , inout bit[<%=obj.wSecurityAttribute%>-1:0] security
            <% } %>
            ,inout bit is_coh
            ,input bit use_addr_from_test = 0, input axi_axaddr_t m_ace_rd_addr_from_test = 0
            <%if(obj.wSecurityAttribute > 0) { %>                                             
                , input bit[<%=obj.wSecurityAttribute%>-1:0] m_ace_rd_security_from_test = 0 
            <% } %>
        );
            aceState_t             m_state_of_addr;
            bit                                               success = 0;
            int                                               m_tmp_q[$];
            int                                               m_tmp_qA[$];
            int                                               count;
            int                                               zcount = 0;
            int                                               do_count;
            int                                               addr_set;

            is_coh = calculate_is_coh(cmdtype);


            
            
            <% if (obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5" ||(obj.Block === 'mem' && obj.is_master === 1)) { %>    
                success = 1;
                m_state_of_addr = ACE_IX;
            <%}else { %>    
                success = calculate_start_state(cmdtype, m_state_of_addr, is_coh);
            <%}%>
	    `uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("tsk:give_addr_for_ace_req_read id:%0d CmdType:%0s isCoh:%0b state_of_addr:%0p", id, cmdtype, is_coh, m_state_of_addr), UVM_LOW);
            
            if (success) begin
                bit tmp_security;
                bit [addrMgrConst::W_SEC_ADDR - 1: 0] sec_addr;
                int pick_itr;
                int pick_itr_q[$];

                if (m_state_of_addr == ACE_IX) begin
                    bit done = 0;
                    bit non_coh_addr;

                    non_coh_addr = !is_coh;
                    do begin
                        bit [63:0] m_ort_addr_q[$];
                        m_ort_addr_q = {};
                        <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                            foreach (m_ort[i]) begin
                                m_ort_addr_q.push_back(m_ort[i].m_addr);
                            end
                            foreach (m_stt[i]) begin
                                m_ort_addr_q.push_back(m_stt[i].m_addr);
                            end
                        <% } %>
                        <% if(obj.testBench === "aiu") { %>
                            if (non_coh_addr) begin

                               //`uvm_info("HS_DBG", $sformatf("noncoh_addr core_id:%0d", core_id), UVM_NONE)
                                sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                                tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                                addr     = sec_addr;

                            end else if ($urandom_range(0,100) < prob_of_new_addr) begin
                               //`uvm_info("HS_DBG", $sformatf("new_addr core_id:%0d", core_id), UVM_NONE)
                                sec_addr = this.gen_new_cacheline(funitid, 1, core_id);
                                tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                                addr     = sec_addr;
                            end else begin
                               //`uvm_info("HS_DBG", $sformatf("coh_addr core_id:%0d", core_id), UVM_NONE)
                                sec_addr = m_addr_mgr.get_coh_addr(funitid, 1, 0, core_id);
                                tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                                addr     = sec_addr;
                            end
                        <% } else { %>
                            if (non_coh_addr) begin
                                int  gen_addr_to_dmi = <%=obj.DiiInfo.length%> < 2 ? 1 :$urandom_range(0,99) < prob_of_dmi_dii_addr ? 1 : 0;
                                if ((addrMgrConst::aiu_connected_dii_ids[funitid].ConnectedfUnitIds.size() == 0) ||
                                    ((addrMgrConst::aiu_connected_dii_ids[funitid].ConnectedfUnitIds.size() == 1) && (addrMgrConst::aiu_connected_dii_ids[funitid].ConnectedfUnitIds[0] == addrMgrConst::funit_ids[addrMgrConst::diiIds[addrMgrConst::get_sys_dii_idx()]]))
                                   )  begin
                                  gen_addr_to_dmi = 1;//force DMI target as no DII is connected for this agent   
                                end  
                                if($test$plusargs("use_user_addrq") && (user_addrq[addrMgrConst::NONCOH].size()>0)) begin
                                if($test$plusargs("use_user_write_read_addrq") || $test$plusargs("use_user_rw_addrq")) begin: _some_perf_plusargs_
                                    if(user_read_addrq_idx[addrMgrConst::NONCOH] == -1) begin
                                        bit brek;
                                        count = 0;
                                        do begin
                                            count++;
                                            pick_itr = $urandom_range(user_read_addrq[addrMgrConst::NONCOH].size()-1);
                                            sec_addr = user_read_addrq[addrMgrConst::NONCOH][pick_itr];
                                            sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                            if (current_cache_state(sec_addr
                                                <% if (obj.wSecurityAttribute > 0) { %>
                                                ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                <% } %>
                                                ) == ACE_IX) begin
                                                brek = 1;
                                            end
                                        end while((!brek) && (count < 1000));
                                    end
                                    else begin
                                        <% if(obj.testBench == "fsys") { %>
                                        if($test$plusargs("individual_initiator_addrq")) begin
                                            sec_addr = user_read_addrq[addrMgrConst::NONCOH][((<%=obj.nCHIs%>*num_trans_per_chi) + (<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn%>)*num_trans_per_ioaiu) + user_read_addrq_idx[addrMgrConst::NONCOH]];
                                        end else begin
                                            sec_addr = user_read_addrq[addrMgrConst::NONCOH][user_read_addrq_idx[addrMgrConst::NONCOH]];
                                        end
                                        <% } else { %>
                                        sec_addr = user_read_addrq[addrMgrConst::NONCOH][user_read_addrq_idx[addrMgrConst::NONCOH]];
                                        <% } %>
                                        sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);

                                        if(!$test$plusargs("force_unique_addr")) user_read_addrq_idx[addrMgrConst::NONCOH] = user_read_addrq_idx[addrMgrConst::NONCOH] + 1;
                                        if(user_read_addrq_idx[addrMgrConst::NONCOH] >= user_read_addrq[addrMgrConst::NONCOH].size()) begin
                                            user_read_addrq_idx[addrMgrConst::NONCOH] = 0;
                                        end
                                    end 
                                end: _some_perf_plusargs_

                                else begin
                                    //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_req_read id:%0d user_addrq.NONCOH.size:%0d user_addrq_idx[addrMgrConst::NONCOH]:%0d", id, user_addrq[addrMgrConst::NONCOH].size(), user_addrq_idx[addrMgrConst::NONCOH]), UVM_LOW);

                                    if(user_addrq_idx[addrMgrConst::NONCOH] == -1) begin
                                        bit brek;
                                        pick_itr_q = {};
                                        do begin
                                            brek = 0;
                                            assert(std::randomize(pick_itr) with {(!(pick_itr inside {pick_itr_q})) && (pick_itr inside {[0:user_addrq[addrMgrConst::NONCOH].size()-1]});})
                                            else `uvm_error("ACE CACHE MODEL", $sformatf("fn:give_addr_for_ace_req_read id:%0d Failure to randomize pick_itr in NONCOH addrq", id));
                                            pick_itr_q.push_back(pick_itr);
                                            sec_addr = user_addrq[addrMgrConst::NONCOH][pick_itr];
                                            sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                            if ((current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) == ACE_IX) &&
                                                 check_if_addr_is_ok_to_send(cmdtype, sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>)) begin
                                                brek = 1;
                                            end
                                            <% if ( obj.initiatorGroups.length >= 1) { %>
                                            addr     = sec_addr;
                                            if(!$test$plusargs("check_unmapped_add") && addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected)) begin
                                                brek = 0; // Force random picked address into user_addrq to be connected to the initiator
                                            end
                                            <% } %>
                                            `uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_read_req NONCOH pick_itr_q %0p and brek:%0d",pick_itr_q,brek), UVM_LOW);
                                        end while((!brek) && (pick_itr_q.size() < user_addrq[addrMgrConst::NONCOH].size()));
                                        if(pick_itr_q.size() == user_addrq[addrMgrConst::NONCOH].size() && !brek) begin
                                        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                                            s_coh_noncoh.put();
                                        <%}%>
                                            return 0;
                                        end
                                    end
                                    else begin
                                        bit brek = 0;
                                        int kcount = 0;
                                        do begin 
                                            brek = 0;
                                            kcount++;
                                            //`uvm_info(get_full_name(), $sformatf("DBG: fn:give_addr_for_ace_req_read id:%0d finding user_addrq[addrMgrConst::NONCOH] IX addr kcount:%0d idx:%0d", id, kcount, user_addrq_idx[addrMgrConst::NONCOH]), UVM_LOW);

                                            if($test$plusargs("individual_initiator_addrq")) begin
                                                sec_addr = user_addrq[addrMgrConst::NONCOH][(<%=obj.nCHIs%>*num_trans_per_chi) + ((<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn%>)*num_trans_per_ioaiu) + user_addrq_idx[addrMgrConst::NONCOH]];
                                            end else begin
                                                sec_addr = user_addrq[addrMgrConst::NONCOH][user_addrq_idx[addrMgrConst::NONCOH]];
                                            end
                                            sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);

                                            if(!$test$plusargs("force_unique_addr")) user_addrq_idx[addrMgrConst::NONCOH] = user_addrq_idx[addrMgrConst::NONCOH] + 1;
                                            if(user_addrq_idx[addrMgrConst::NONCOH] >= user_addrq[addrMgrConst::NONCOH].size() || (use_loop_addr>0 && user_addrq_idx[addrMgrConst::NONCOH] >= use_loop_addr)) begin
                                                user_addrq_idx[addrMgrConst::NONCOH] = use_loop_addr_offset;
                                                use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                                use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                            end
                                            if ((current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) == ACE_IX) && 
                                                check_if_addr_is_ok_to_send(cmdtype, sec_addr <% if (obj.wSecurityAttribute > 0) { %> ,sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>))begin
                                                    brek = 1;
                                                end
                                        end while ((brek==0) && (kcount < user_addrq[addrMgrConst::NONCOH].size()));
                                        
                                        if (brek==0) begin 
                                            //`uvm_info(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_noncoh_write no IX address found in user_addrq[addrMgrConst::NONCOH] cmdtype:%0s isCoh:%0d", cmdtype, is_coh), UVM_LOW);
                                        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || (obj.Block === 'mem' && obj.is_master === 1)) { %>
                                            s_coh_noncoh.put();
                                        <%}%>
                                            return 0;
                                        end
                                    end
				end
                                m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, funitid); 
                            end 
                            else if ($urandom_range(0,100) < prob_of_new_addr) begin
                                bit brek;
                                count = 0;
                                do begin
                                    count++;
                                    <% if(obj.testBench == "io_aiu" || obj.testBench == "fsys") { %>
                                        if(gen_addr_to_dmi) begin
                                            sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);
                                        end else begin
                                            sec_addr = m_addr_mgr.gen_iocoh_addr(funitid, 1, 1, core_id);
<%if (obj.testBench == "fsys") {%>
// Override sec_addr if GEN_SEL_TARG_ADDR is true since user wants addr only from selected target
                                            if(GEN_SEL_TARG_ADDR==1)  sec_addr = gen_sel_targ_addr_from_unit_attr(test_targ_unit_type,test_targ_unit_id,test_targ_index_in_group,test_targ_nc);
<% } %>
                                        end
                                    <% } else { %>
                                        sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);
                                    <% } %>
                                    if (current_cache_state(sec_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                        <% } %>) == ACE_IX) begin
                                        brek = 1;
                                    end
                                end while((!brek) && (count < 1000));
                                if(!brek) begin
                                    <% if(obj.testBench == "io_aiu" || obj.testBench == "fsys") { %>
                                        if(gen_addr_to_dmi) begin
                                            sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                                        end else begin
                                            sec_addr = m_addr_mgr.get_iocoh_addr(funitid, 1, core_id);
<%if (obj.testBench == "fsys") {%>
// Override sec_addr if GEN_SEL_TARG_ADDR is true since user wants addr only from selected target
                                            if(GEN_SEL_TARG_ADDR==1)  sec_addr = gen_sel_targ_addr_from_unit_attr(test_targ_unit_type,test_targ_unit_id,test_targ_index_in_group,test_targ_nc);
<% } %>
                                        end
                                    <% } else { %>
                                        sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                                    <% } %>
                                end
                            end else begin
                                bit brek;
                                count = 0;
                                do begin
                                    count++;
                                    <% if(obj.testBench == "io_aiu" || obj.testBench == "fsys") { %>
                                        if(gen_addr_to_dmi) begin
                                            sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                                        end else begin
                                            sec_addr = m_addr_mgr.get_iocoh_addr(funitid, 1, core_id);
<%if (obj.testBench == "fsys") {%>
// Override sec_addr if GEN_SEL_TARG_ADDR is true since user wants addr only from selected target
                                            if(GEN_SEL_TARG_ADDR==1)  sec_addr = gen_sel_targ_addr_from_unit_attr(test_targ_unit_type,test_targ_unit_id,test_targ_index_in_group,test_targ_nc);
<% } %>
                                        end
                                    <% } else { %>
                                        sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                                    <% } %>
                                    if (current_cache_state(sec_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                        <% } %>) == ACE_IX) begin
                                        brek = 1;
                                    end
                                end while((!brek) && (count < 1000));
                                    if(!brek) begin
                                        <% if(obj.testBench == "io_aiu" || obj.testBench == "fsys") { %>
                                            if(gen_addr_to_dmi) begin
                                                sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);
                                            end else begin
                                                sec_addr = m_addr_mgr.gen_iocoh_addr(funitid, 1, 1, core_id);
<%if (obj.testBench == "fsys") {%>
// Override sec_addr if GEN_SEL_TARG_ADDR is true since user wants addr only from selected target
                                            if(GEN_SEL_TARG_ADDR==1)  sec_addr = gen_sel_targ_addr_from_unit_attr(test_targ_unit_type,test_targ_unit_id,test_targ_index_in_group,test_targ_nc);
<% } %>
                                            end
                                        <% } else { %>
                                            sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);                                        
                                        <% } %>
                                    end
                                end
                                tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                                addr     = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                            end else begin
                              <% if( (obj.testBench == "fsys" || obj.testBench == "emu") ) { %>    
                                if($test$plusargs("use_user_addrq")  && (user_addrq[addrMgrConst::COH].size()>0)) begin
                              <% } else { %>
                                if($test$plusargs("use_user_addrq")) begin
                              <% } %>
                                    if($test$plusargs("use_user_write_read_addrq") || $test$plusargs("use_user_rw_addrq")) begin
                                        if(user_read_addrq_idx[addrMgrConst::COH] == -1) begin
                                            bit brek;
                                            count = 0;
                                            do begin
                                                count++;
                                                pick_itr = $urandom_range(user_read_addrq[addrMgrConst::COH].size()-1);
                                                sec_addr = user_read_addrq[addrMgrConst::COH][pick_itr];
                                                sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                                if (current_cache_state(sec_addr
                                                    <% if (obj.wSecurityAttribute > 0) { %>
                                                        ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                    <% } %>
                                                    ) == ACE_IX) begin
                                                    brek = 1;
                                                end
                                            end while((!brek) && (count < 1000));
                                        end
                                        else begin
                                            <% if(obj.testBench == "fsys") { %>
                                            if($test$plusargs("individual_initiator_addrq")) begin
                                                
                                                sec_addr = user_read_addrq[addrMgrConst::COH][((<%=obj.nCHIs%>*num_trans_per_chi) + (<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn%>)*num_trans_per_ioaiu) + user_read_addrq_idx[addrMgrConst::COH]];
                                            end else begin
                                                sec_addr = user_read_addrq[addrMgrConst::COH][user_read_addrq_idx[addrMgrConst::COH]];
                                            end
                                            <% } else { %>
                                            sec_addr = user_read_addrq[addrMgrConst::COH][user_read_addrq_idx[addrMgrConst::COH]];
                                            <% } %>

                                            sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);

                                            if(!$test$plusargs("force_unique_addr"))user_read_addrq_idx[addrMgrConst::COH] = user_read_addrq_idx[addrMgrConst::COH] + 1;
                                            if(user_read_addrq_idx[addrMgrConst::COH] >= user_read_addrq[addrMgrConst::COH].size()) begin
                                                user_read_addrq_idx[addrMgrConst::COH] = 0;
                                            end
                                        end 
                                    end 
				    else begin
                                        //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_req_read id:%0d user_addrq.COH.size:%0d user_addrq_idx[addrMgrConst::COH]:%0d", id, user_addrq[addrMgrConst::COH].size(), user_addrq_idx[addrMgrConst::COH]), UVM_LOW);


                                        if(user_addrq_idx[addrMgrConst::COH] == -1) begin
                                            bit brek;
                                            pick_itr_q = {};
                                            do begin
                                                assert(std::randomize(pick_itr) with {(!(pick_itr inside {pick_itr_q})) && (pick_itr inside {[0:user_addrq[addrMgrConst::COH].size()-1]});})
                                                else 
                                                `uvm_error("ACE CACHE MODEL", "Failure to randomize pick_itr");
                                                pick_itr_q.push_back(pick_itr);
                                                sec_addr = user_addrq[addrMgrConst::COH][pick_itr];
                                                sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                                if (current_cache_state(sec_addr
                                                    <% if (obj.wSecurityAttribute > 0) { %>
                                                    ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                    <% } %>
                                                    ) == ACE_IX) begin
                                                brek = 1;
                                                <% if ( obj.initiatorGroups.length >= 1) { %>
                                            addr     = sec_addr;
                                            if(!$test$plusargs("check_unmapped_add") && addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected)) begin
                                                brek = 0;  // Force random picked address into user_addrq to be connected to the initiator
                                            end
                                            <% } %>
                                            end
                                            //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_coh_read pick_itr_q %0p and brek:%0d",pick_itr_q,brek), UVM_LOW);
                                        end while((!brek) && (pick_itr_q.size() < user_addrq[addrMgrConst::COH].size()));
                                      
                                        if(pick_itr_q.size() == user_addrq[addrMgrConst::COH].size() && !brek) begin
                                        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                                            s_coh_noncoh.put();
                                        <%}%>
                                            return 0;
                                        end

                                    end
                                    else begin
                                        bit brek;
                                        do begin
                                            brek = 0;
                                            zcount++;
                                            //`uvm_info(get_full_name(), $sformatf("DBG: fn:give_addr_for_ace_req_read id:%0d finding user_addrq[addrMgrConst::COH] IX addr zcount:%0d idx:%0d", id, zcount, user_addrq_idx[addrMgrConst::COH]), UVM_NONE);
                                            if($test$plusargs("individual_initiator_addrq")) begin
                                                sec_addr = user_addrq[addrMgrConst::COH][(<%=obj.nCHIs%>*num_trans_per_chi) + ((<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts>1 ? obj.AiuInfo[obj.Id].rpn[0] : obj.AiuInfo[obj.Id].rpn%>)*num_trans_per_ioaiu) + user_addrq_idx[addrMgrConst::COH]];
                                                 sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                            end else begin
                                                sec_addr = user_addrq[addrMgrConst::COH][user_addrq_idx[addrMgrConst::COH]];
                                                sec_addr = addrMgrConst::update_addr_for_core(sec_addr,funitid, core_id);
                                            end

                                            if(!$test$plusargs("force_unique_addr")) user_addrq_idx[addrMgrConst::COH] = user_addrq_idx[addrMgrConst::COH] + 1;
                                            if(user_addrq_idx[addrMgrConst::COH] >= user_addrq[addrMgrConst::COH].size() || (use_loop_addr>0 && user_addrq_idx[addrMgrConst::COH] >= use_loop_addr)) begin
                                                user_addrq_idx[addrMgrConst::COH] = use_loop_addr_offset;
                                                use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
                                                use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
                                            end
                                            if ((current_cache_state(sec_addr <% if (obj.wSecurityAttribute > 0) { %> , sec_addr[addrMgrConst::W_SEC_ADDR - 1] <% } %>) == ACE_IX) && 
                                                (check_if_addr_is_ok_to_send(cmdtype, addr <% if (obj.wSecurityAttribute > 0) { %> ,security <% } %>) == 1)) begin
                                                brek = 1;
                                            end 

                                           // `uvm_info(get_full_name(), $sformatf("DBG: fn:give_addr_for_ace_req_read inside do-while find in user_addrq[addrMgrConst::COH] IX zcount:%0d idx:%0d",zcount, user_addrq_idx[addrMgrConst::COH]), UVM_NONE);
                                        end while ((brek==0) && (zcount < user_addrq[addrMgrConst::COH].size()));
                                        
                                        if (brek==0) begin 
                                            //`uvm_info(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_req_read no IX address found in user_addrq[addrMgrConst::COH] so return cmdtype:%0s isCoh:%0d", cmdtype, is_coh), UVM_LOW);
                                            return 0;
                                        end else begin 
                                            //`uvm_info(get_full_name(), $sformatf("TB Error: fn:give_addr_for_ace_req_read IX address found in user_addrq[addrMgrConst::COH] cmdtype:%0s isCoh:%0d addr:0x%0h sec:%0b", cmdtype, is_coh, sec_addr, sec_addr[addrMgrConst::W_SEC_ADDR - 1]), UVM_LOW);
                                        end 
                                    end
                                end
				end else if ($urandom_range(0,100) < prob_of_new_addr) begin
                                    bit brek;
                                    count = 0;
                                    do begin
                                        count++;
                                        sec_addr = this.gen_new_cacheline(funitid, 1, core_id);
                                        if (current_cache_state(sec_addr
                                            <% if (obj.wSecurityAttribute > 0) { %>
                                            ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                            <% } %>) == ACE_IX) begin
                                            brek = 1;
                                        end
                                    end while((!brek) && (count < 1000));
                                    if(!brek) begin
                                        count = 0;
                                        do begin
                                            count++;
                                            sec_addr = m_addr_mgr.get_coh_addr(funitid, 1, 0, core_id);
                                            if (current_cache_state(sec_addr
                                                <% if (obj.wSecurityAttribute > 0) { %>
                                                ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                <% } %>
                                                ) == ACE_IX) begin
                                                break;
                                            end
                                        end while (count < 1000);
                                        if(count == 1000) begin
                                            $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function give_addr_for_ace_req_read function, address manager can't return any address which has cache state IX"), UVM_NONE);
                                        end
                                    end
                                end else begin
                                    bit brek;
                                    count = 0;
                                    do begin
                                        count++;
                                        sec_addr = m_addr_mgr.get_coh_addr(funitid, 1, 0, core_id);
                                        if (current_cache_state(sec_addr
                                            <% if (obj.wSecurityAttribute > 0) { %>
                                            ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                            <% } %>
                                        ) == ACE_IX) begin
                                            brek = 1;
                                        end
                                    end while((!brek) && (count < 1000));
                                    if(!brek) begin
                                        count = 0;
                                        do begin
                                            count++;
                                            sec_addr = this.gen_new_cacheline(funitid, 1, core_id);
                                            if (current_cache_state(sec_addr
                                                <% if (obj.wSecurityAttribute > 0) { %>
                                                    ,sec_addr[addrMgrConst::W_SEC_ADDR - 1]
                                                <% } %>
                                                ) == ACE_IX) begin
                                                break;
                                            end
                                        end while (count < 1000);
                                        if(count == 1000) begin
                                            $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function give_addr_for_ace_req_read function, address manager can't return any address which has cache state IX"), UVM_NONE);
                                        end
                                    end
                                end
                                tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                                addr     = sec_addr;
                            end
                        <%}%>
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            security = tmp_security;
                        <%}%>                                                
                            if (check_if_addr_is_ok_to_send(cmdtype, addr
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    ,security
                                <% } %>                                                
                            )) begin
                                done = 1;
                            end
			    do_count++; //avoid eternal loop				
                if (do_count >10000) break;
		end while ((!done) || addrMgrConst::check_unmapped_add(addr, funitid, unit_unconnected));//#TRY_TO_GEx_RD_ADDR
                    if (do_count > 10000) begin
                        $stacktrace();
                        `uvm_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function give_addr_for_ace_req_read unable to find addr even after 10000 iterations for Cmdtype %0s isCoh:%0d m_state_of_addr:%0p", cmdtype, is_coh, m_state_of_addr));
                        return 0;
                    end    
                    if (current_cache_state(addr <% if (obj.wSecurityAttribute > 0) { %>,security<% } %>) !== ACE_IX) begin
                        bit is_non_coherent_address;
                        int m_tmp_q[$];
                        m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                        <% if (obj.wSecurityAttribute > 0) { %> && item.m_security == security<% } %>);
                        if (m_tmp_q.size() > 1) begin
                            $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: found multiple copies of address 0x%0x in cache model", addr), UVM_NONE);
                        end
                        else if (m_tmp_q.size() == 0) begin
                            is_non_coherent_address = 0;
                        end
                        else begin
                            is_non_coherent_address = m_cache[m_tmp_q[0]].m_non_coherent_addr;
                        end
                        if( ! is_non_coherent_address) begin
                          //if (!$test$plusargs("use_seq_user_addrq")) begin
                               $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function give_addr_for_ace_req_read address 0x%0x returned by address manager is already in cache in state %p", addr, current_cache_state(addr<% if (obj.wSecurityAttribute > 0) { %>,security<% }%>)), UVM_NONE);
                          //end
                        end
                    end
                end
                else begin
                    m_tmp_q = {};
                    m_tmp_qA = {};
                    if(!$cast(tmp_aceState, m_state_of_addr))
                        `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
                    m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState);
		    foreach(m_tmp_qA[i]) begin 
                    	//`uvm_info($sformatf("DBG ACE CACHE MODEL%s", get_full_name()), $sformatf("%0s",m_cache[m_tmp_qA[i]].sprint_pkt()), UVM_LOW);
		    end
                    foreach(m_tmp_qA[i]) begin
                        if (!is_coh) begin
                            if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 1) begin
                                if(cmdtype == RDNOSNP ||
                                cmdtype == WRNOSNP
                                ) begin
                                    if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,m_cache[m_tmp_qA[i]].m_security
                                        <% } %>
                                    )) begin
                                        m_tmp_q.push_back(m_tmp_qA[i]);
                                    end
                                end else begin
                                    if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,m_cache[m_tmp_qA[i]].m_security
                                        <% } %>
                                    )) begin
                                        m_tmp_q.push_back(m_tmp_qA[i]);
                                    end
                                end
                            end
                        end
                        else if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 0) begin
                            if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    ,m_cache[m_tmp_qA[i]].m_security
                                <% } %>                                                
                            )) begin
                                m_tmp_q.push_back(m_tmp_qA[i]);
                            end
                        end
                    end
                    if (m_tmp_q.size() == 0) begin
                        `uvm_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error in give_addr_for_ace_req_read: Cannot find state %0s in cache for cmdtype %0p. ", m_state_of_addr.name(), cmdtype));
                        return 0;
                    end
                    else begin
                        m_tmp_q.shuffle();
                        addr = m_cache[m_tmp_q[0]].m_addr;
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            security = m_cache[m_tmp_q[0]].m_security;
                        <% } %>                                                
                        `uvm_info("give_addr_for_ace_req_read", $sformatf("Selected address 0x%0x", addr), UVM_MEDIUM);
                    end
                end
            end
    
            if (use_addr_from_test) begin
                addr = m_ace_rd_addr_from_test;
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    security = m_ace_rd_security_from_test;
                <% } %>                                                
            end
            if (success) begin
                ORT_struct_t m_tmp_var;
                m_tmp_var.m_cmdtype = cmdtype;
                m_tmp_var.isUpdate  = 0;
                m_tmp_var.isRead    = 1;
                m_tmp_var.m_addr    = addr;
                m_tmp_var.m_security = security;
                m_tmp_var.isNonCoh  = !is_coh;
                m_tmp_var.t_creation = $time;
                <% if(obj.testBench == "fsys") { %>
                if ($test$plusargs("random_gpra_nsx")) begin
                  //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                    m_tmp_var.m_security = addrMgrConst::get_addr_gprar_nsx(m_tmp_var.m_addr) ;
                end 
                <% } %> 
                //`uvm_info(get_full_name(), $sformatf("fn:give_addr_for_ace_req_read Pushed into ORT from initial_state:%0s cmdtype:%0p addr:0x%0h sec:%0b", current_cache_state(m_tmp_var.m_addr <% if (obj.wSecurityAttribute > 0) { %> , m_tmp_var.m_security <% } %>), m_tmp_var.m_cmdtype, m_tmp_var.m_addr, m_tmp_var.m_security), UVM_LOW);
              
                m_ort.push_back(m_tmp_var);
                //foreach (m_ort[i]) begin
                //    `uvm_info("ORT_after_push_back_req_read", $sformatf("idx:%0d %0p", i, m_ort[i]), UVM_LOW);
                //end

                <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                    ->e_cache_modify;
                <% } %>                     
            end
            return success;
        endfunction : give_addr_for_ace_req_read

        function void give_addr_for_exclusive_req(output axi_axaddr_t addr);
            bit [addrMgrConst::W_SEC_ADDR - 1: 0] sec_addr;
            bit tmp_security;

            // TODO: Need to add knob in address manager to support exclusive_acc
            sec_addr = m_addr_mgr.gen_coh_addr(funitid, 1, -1, -1, -1, -1, core_id);
            tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
            addr     = sec_addr;
        endfunction: give_addr_for_exclusive_req


        function give_addr_for_io_cache(input ace_command_types_enum_t cmdtype,
                                        output axi_axaddr_t addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                , inout bit[<%=obj.wSecurityAttribute%>-1:0] security
            <% } %>                                                
            , input axi_axaddr_t addr_arr[] = '{});
            bit exclusive_acc;
            bit non_coh_addr;
            int addr_set;
            ORT_struct_t m_tmp_var;
            bit [63:0] m_ort_addr_q[$];
            bit tmp_security;
            bit [addrMgrConst::W_SEC_ADDR - 1: 0] sec_addr;

            foreach (m_ort[i]) begin
                m_ort_addr_q.push_back(m_ort[i].m_addr);
            end
            foreach (m_stt[i]) begin
                m_ort_addr_q.push_back(m_stt[i].m_addr);
            end
            foreach (addr_arr[i]) begin
                m_ort_addr_q.push_back(addr_arr[i]);
            end
            exclusive_acc = 1'b0;
            
            if ($urandom_range(1,100) < prob_ace_coh_win_error) begin
                non_coh_addr = 1;
            end
            else begin
                non_coh_addr = 0;
            end
            <% if(obj.useIoCache) { %>
                if (non_coh_addr) begin
                    sec_addr = m_addr_mgr.get_noncoh_addr(funitid, 1, core_id);
                    tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                    addr     = sec_addr;
                end else if ($urandom_range(0,100) < prob_of_new_addr) begin
                    sec_addr = this.gen_new_cacheline(funitid, 1, core_id);
                    tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                    addr     = sec_addr;
                end else begin
                    sec_addr = m_addr_mgr.get_coh_addr(funitid, 1, 0, core_id);
                    tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                    addr     = sec_addr;
                end
            <% } else { %>
                sec_addr = m_addr_mgr.get_coh_addr(funitid, 1, 0, core_id);
                tmp_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
                addr     = sec_addr;
            <% } %>
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                security = tmp_security;
            <% } %>                                                

            m_tmp_var.m_cmdtype = cmdtype;
            m_tmp_var.m_addr    = addr;
            m_tmp_var.isUpdate  = 0;
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_tmp_var.m_security = security;
            <% } %>                                                
            if (m_tmp_var.m_cmdtype == WRNOSNP ||
                m_tmp_var.m_cmdtype == WRUNQ   ||
                m_tmp_var.m_cmdtype == WRLNUNQ ||
                m_tmp_var.m_cmdtype == WREVCT  ||
                m_tmp_var.m_cmdtype == WRBK    ||
                m_tmp_var.m_cmdtype == EVCT    ||
                m_tmp_var.m_cmdtype == WRCLN
            ) begin
                m_tmp_var.isRead = 0;
                if (m_tmp_var.m_cmdtype == WREVCT  ||
                    m_tmp_var.m_cmdtype == WRBK    ||
                    m_tmp_var.m_cmdtype == EVCT    ||
                    m_tmp_var.m_cmdtype == WRCLN
                ) begin
                    m_tmp_var.isUpdate = 1;
                end
            end
            else begin
                m_tmp_var.isRead = 1;
            end
            m_tmp_var.t_creation = $time;
            <% if(obj.testBench == "fsys") { %>
            if ($test$plusargs("random_gpra_nsx")) begin
                //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                m_tmp_var.m_security = addrMgrConst::get_addr_gprar_nsx(m_tmp_var.m_addr) ;
            end
            <% } %> 
            m_ort.push_back(m_tmp_var);
            <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                ->e_cache_modify;
            <% } %>                                                
        endfunction: give_addr_for_io_cache

        function void store_exclusive_req(ace_command_types_enum_t cmdtype,
                                        axi_axaddr_t addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                , inout bit[<%=obj.wSecurityAttribute%>-1:0] security
            <% } %>);
            ORT_struct_t m_tmp_var;

            m_tmp_var.m_cmdtype = cmdtype;
            m_tmp_var.m_addr = addr;
            m_tmp_var.isUpdate  = 0;
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_tmp_var.m_security = security;
            <% } %>
            if (m_tmp_var.m_cmdtype == WRNOSNP ||
                m_tmp_var.m_cmdtype == WRUNQ   ||
                m_tmp_var.m_cmdtype == WRLNUNQ ||
                m_tmp_var.m_cmdtype == WREVCT  ||
                m_tmp_var.m_cmdtype == WRBK    ||
                m_tmp_var.m_cmdtype == EVCT    ||
                m_tmp_var.m_cmdtype == WRCLN
            ) begin
                m_tmp_var.isRead = 0;
                if (m_tmp_var.m_cmdtype == WREVCT  ||
                    m_tmp_var.m_cmdtype == WRBK    ||
                    m_tmp_var.m_cmdtype == EVCT    ||
                    m_tmp_var.m_cmdtype == WRCLN
                ) begin
                    m_tmp_var.isUpdate = 1;
                end
            end
            else begin
                m_tmp_var.isRead = 1;
            end
            m_tmp_var.t_creation = $time;
            <% if(obj.testBench == "fsys") { %>
            if ($test$plusargs("random_gpra_nsx")) begin
                //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                m_tmp_var.m_security = addrMgrConst::get_addr_gprar_nsx(m_tmp_var.m_addr) ;
            end
            <% } %> 
            m_ort.push_back(m_tmp_var);
            <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                ->e_cache_modify;
            <% } %>                                                
        endfunction: store_exclusive_req

        function void update_addr(ace_command_types_enum_t cmdtype, axi_axaddr_t addr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    , bit[<%=obj.wSecurityAttribute%>-1:0] security
                <% } %>
            );
            int m_tmp_q[$];
                
            m_tmp_q = {};
            //128B exclusive has to be aligned or addr might be updated such
            //that total transfer does not cross 4KB boundary. so [11:0] bits
            //of address could mismatch after address comes out of axi_txn:
            //randomization.
            m_tmp_q = m_ort.find_last_index with (item.m_addr[WAXADDR-1:12] == addr[WAXADDR-1:12] &&
                    item.m_cmdtype == cmdtype
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        && item.m_security == security
                    <% } %>                                                
                );
            
            if (m_tmp_q.size == 0) begin
                $stacktrace();
                `uvm_error("ACE CACHE MODEL", $sformatf("TB Error: In function update_addr Found %0d (instead of 1) copies of address 0x%0x and cmdtype %0s", m_tmp_q.size, addr, cmdtype.name()));
            end
            else begin
                m_ort[m_tmp_q[0]].m_addr = addr;
            end

        endfunction : update_addr

        function void give_data_for_ace_req(axi_axaddr_t addr,
            ace_command_types_enum_t cmdtype,
            axi_axlen_t len,
            axi_axburst_t burst,
            axi_axsize_t size,
            output axi_xdata_t data[],
            output axi_xstrb_t strb[]
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                ,inout bit[<%=obj.wSecurityAttribute%>-1:0] security
            <% } %>
            ); 
            int m_tmp_q[$];
            int m_tmp_qA[$];
            bit use_full_cl;

            use_full_cl = $test$plusargs("use_full_cl") || $test$plusargs("en_all_f_wstrb") || $test$plusargs("perf_test");
            strb = new [len + 1];

            if (((cmdtype inside {WRUNQ, WRNOSNP,WRCLN,WRBK,WRUNQPTLSTASH}) && !use_full_cl) || (cmdtype inside {ATMSTR,ATMLD,ATMSWAP,ATMCOMPARE})) begin
                if ((2**size == (WXDATA/8)) && ((cmdtype inside {WRUNQ,WRNOSNP,WRCLN,WRBK,WRUNQPTLSTASH}) && !use_full_cl)) begin
                    bit [WXDATA/8-1:0] mask;

                    if ($test$plusargs("ptl_wrstrb_only")) begin : _ptl_wr_strbs_only_
                      randcase
                        1: begin //alternating 1s and 0s for each byte wstrb, starting at 0
                            foreach (strb[i]) begin
                                bit temp = 0;
                                for (int j = 0; j < WXDATA/8; j++) begin
                                    strb[i][j] = temp;
                                    temp = ~temp;
                                end
                            end
                        end
                        1: begin //alternating 1s and 0s for each byte wstrb, starting at 1
                            foreach (strb[i]) begin
                                bit temp = 1;
                                for (int j = 0; j < WXDATA/8; j++) begin
                                    strb[i][j] = temp;
                                    temp = ~temp;
                                end
                            end
                        end
                      endcase
                    end : _ptl_wr_strbs_only_
                    else begin: _all_possible_wr_strbs_
                      randcase
                        3: begin //all beats random 
                              foreach (strb[i]) begin
                                  strb[i] = $urandom;
                              end
                            end
                        2 : begin //all beats strb = 1s
                              foreach (strb[i]) begin
                                  strb[i] = '1;
                              end
                            end
                        1 : begin //all beats strb = 0s, no data written hence low probability
                              foreach (strb[i]) begin
                                  strb[i] = '0;
                              end
                            end
                        3 : begin //even beats strb=1s, odd beats random strbs
                              foreach (strb[i]) begin
                                  if (i % 2 == 0)
                                    strb[i] = '1;
                                  else 
                                    strb[i] = $urandom;
                              end
                            end
                        3 : begin //even beats strb=0s, odd beats random strbs
                              foreach (strb[i]) begin
                                if (i % 2 == 0)
                                    strb[i] = '0;
                                else 
                                    strb[i] = $urandom;
                              end
                            end
                        3 : begin //even beats random strbs, odd beats strbs=1s
                              foreach (strb[i]) begin
                                if (i % 2 == 0)
                                    strb[i] = $urandom;
                                else 
                                    strb[i] = '1;
                              end
                            end
                        3 : begin //even beats random strbs, odd beats strbs=0s
                              foreach (strb[i]) begin
                                if (i % 2 == 0)
                                    strb[i] = $urandom;
                                else 
                                    strb[i] = '0;
                              end
                            end
                        3 : begin //pick random beat will have random strbs, all others 1s
                              foreach (strb[i]) begin
                                int j = $urandom_range(0, strb.size()-1);
                                if (i == j)
                                  strb[i] = $urandom;
                                else 
                                  strb[i] = '1;
                              end
                            end
                        3 : begin//pick random beat will have random strbs, all others 0s
                              foreach (strb[i]) begin
                                int j = $urandom_range(0, strb.size()-1);
                                  if (i == j) 
                                    strb[i] = $urandom;
                                  else 
                                    strb[i] = '0;
                              end
                            end
                        3 : begin //pick random beat will have 1s strbs, all others 0s
                              foreach (strb[i]) begin
                                int j = $urandom_range(0, strb.size()-1);
                                  if (i == j)
                                    strb[i] = '1;
                                  else 
                                    strb[i] = '0;
                              end
                            end
                        3 : begin//pick random beat will have 0s strbs, all others 1s
                              foreach (strb[i]) begin
                                int j = $urandom_range(0, strb.size()-1);
                                  if (i == j) 
                                    strb[i] = '0;
                                  else 
                                    strb[i] = '1;
                              end
                            end
                        2 : begin //alternating 1s and 0s for each byte wstrb, starting at 0
                            foreach (strb[i]) begin
                                bit temp = 0;
                                for (int j = 0; j < WXDATA/8; j++) begin
                                    strb[i][j] = temp;
                                    temp = ~temp;
                                end
                            end
                        end
                        2 : begin //alternating 1s and 0s for each byte wstrb, starting at 1
                            foreach (strb[i]) begin
                                bit temp = 1;
                                for (int j = 0; j < WXDATA/8; j++) begin
                                    strb[i][j] = temp;
                                    temp = ~temp;
                                end
                            end
                        end
                        1 : begin //legacy, only one byte in last beat is asserted
                              foreach (strb[i]) begin
                                if (i == strb.size()-1) begin
                                  strb[i] = 1 << (WXDATA/8 - 1);
                                end
                                else begin
                                  strb[i] = '0;
                                end
                              end
                            end
                        1 : begin //legacy, only one byte in some random beat is asserted
                              foreach (strb[i]) begin
                                int j = $urandom_range(0, strb.size()-1);
                                if (i == j) begin
                                  strb[i] = 1 << (WXDATA/8 - 1);
                                end
                                else begin
                                  strb[i] = '0;
                                end
                              end
                            end
                      endcase
                    end: _all_possible_wr_strbs_

                    // For the first strobe, making sure that all byte enables less than request address in the first beat is 0
                    mask = '1;
                    mask = mask << (addr%(WXDATA/8));
                    strb[0] = strb[0] & mask;
                    
                end
                else begin
                    axi_axaddr_t addr_tmp = addr;
                    int size_p2, size_up;
                    size_p2 = 2**size;
                    for (int j = 0; j <= len; j++) begin
                        size_up = size_p2 - (addr_tmp%size_p2);
                        for (int i = 0; i < size_up; i++) begin
                            strb[j][addr_tmp%(WXDATA/8) + i] = 'b1;
                        end
                        addr_tmp += size_up;
                    end
                end
            end
            else begin
                axi_axaddr_t addr_tmp = addr;
                int size_p2, size_up;
                size_p2 = 2**size;
                for (int j = 0; j <= len; j++) begin
                    size_up = size_p2 - (addr_tmp%size_p2);
                    for (int i = 0; i < size_up; i++) begin
                        strb[j][addr_tmp%(WXDATA/8) + i] = 'b1;
                    end
                    addr_tmp += size_up;
                end
            end
            // If address is not beat aligned, all strobes between address and beat-aligned address should be 0. This can only happen for the first beat
            if (addr[WLOGXDATA-1:0] !== 0) begin
                for (int i = 0; i < addr[WLOGXDATA-1:0] ; i++) begin
                    strb[0][i] = 1'b0;
                end
            end
                    
            //`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("cmdtype:%0p addr:0x%0h sec:%0b len:%0d burst:%0p size:%0p", cmdtype,addr,security, len, burst, size), UVM_LOW);

            //foreach(strb[i]) begin 
            //    `uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("strb[%0d]:0x%0x", i, strb[i]), UVM_LOW);
            //end

            m_tmp_q = {};
            m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                && item.m_security == security
            <% } %>
            );
            if (m_tmp_q.size() > 1) begin
                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function give_data_for_ace_req found multiple copies of address 0x%0x in cache model in give data for ace req", addr), UVM_NONE);
            end
            else if (m_tmp_q.size() == 1 && cmdtype !== WRNOSNP) begin
                int beat_count_of_req;
                bit is_data_capture_done = 0;
                beat_count_of_req = addr[SYS_wSysCacheline-1:WLOGXDATA];
                data = new[len + 1];
                m_tmp_qA= {};
                m_tmp_qA= m_ort.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline] &&
                                                item.m_cmdtype == cmdtype
                <% if (obj.wSecurityAttribute > 0) { %>
                    && item.m_security == security
                <% } %>                                                
                );
                //foreach (m_ort[i]) 
                //   $display("CLUDEBUG m_ort_%0d: addr:%0h cmdtype:%0s",i,m_ort[i].m_addr,m_ort[i].m_cmdtype.name());      
                if (m_tmp_qA.size == 0) begin
                    $stacktrace();uvm_report_error("ACE CACHE MODEL", $sformatf("TB Error: In function give_data_for_ace_req Found %0d (instead of 1) copies of address 0x%0x and cmdtype %0s", m_tmp_qA.size, addr, cmdtype.name()), UVM_NONE);
                end
                // Taking care of weird wrap case seperately
                if (burst == AXIWRAP) begin
                    longint start_addr     = (addr/(WXDATA/8)) * ( WXDATA/8);
                    int num_bytes          = 2 ** size;
                    int burst_length       = len + 1;
                    longint aligned_addr   = (start_addr/(num_bytes)) * num_bytes;
                    int dt_size            = num_bytes * burst_length;
                    longint lower_boundary = (start_addr/(dt_size)) * dt_size;
                    longint upper_boundary = lower_boundary + dt_size;
                    int beat_count         = 0;
                    if ((dt_size < SYS_nSysCacheline) &&  
                        (lower_boundary < ((addr/(WXDATA/8)) * (WXDATA/8))) 
                    ) begin
                        int j = 0;
                        is_data_capture_done = 1;
                        for (int i = 0; i < len + 1; i++) begin 
                            data[i] = m_cache[m_tmp_q[0]].m_data[beat_count_of_req];
                            if (start_addr >= upper_boundary && beat_count == 0) begin
                                beat_count = len + 1 - i;
                            end
                            start_addr = start_addr + num_bytes;
                            beat_count_of_req++;
                            if (beat_count_of_req == SYS_nSysCacheline*8/WXDATA) begin
                                beat_count_of_req = 0;
                            end
                        end
                        beat_count_of_req = addr[SYS_wSysCacheline-1:WLOGXDATA];
                        case (len)
                            1: beat_count_of_req[0] = 0; 
                            3: beat_count_of_req[1:0] = 0; 
                            7: beat_count_of_req[2:0] = 0; 
                            15: beat_count_of_req[3:0] = 0; 
                        endcase
                        for (int i = len + 1 - beat_count; i < len + 1; i++) begin
                            data[i] = m_cache[m_tmp_q[0]].m_data[beat_count_of_req + j];
                            j++;
                            beat_count++;
                        end
                        if (cmdtype == WRUNQ ||
                            cmdtype == WRLNUNQ
                        ) begin
                            foreach(strb[i]) begin
                                axi_xdata_t tmp;
                                axi_xdata_t m_tmp_data1;
                                axi_xdata_t m_tmp_data2;
                                assert(std::randomize(tmp))
                                else begin
                                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), "Failure to randomize tmp", UVM_NONE);
                                end
                                for (int j = 0; j < WXDATA/8; j++) begin
                                    for (int k = 0; k < 8; k++) begin
                                        m_tmp_data1[k+8*j] = tmp[k+8*j] & strb[i][j];
                                        m_tmp_data2[k+8*j] = data[i][k+8*j] & ~strb[i][j];
                                    end
                                end
                                data[i] = m_tmp_data1 | m_tmp_data2;
                            end
                        end
                    end
                end
                if (!is_data_capture_done) begin
                    foreach (data[i]) begin
                        data[i] = m_cache[m_tmp_q[0]].m_data[beat_count_of_req];
                        if (cmdtype == WRUNQ ||
                            cmdtype == WRLNUNQ
                        ) begin
                            axi_xdata_t tmp;
                            axi_xdata_t m_tmp_data1;
                            axi_xdata_t m_tmp_data2;
                            assert(std::randomize(tmp))
                            else begin
                                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), "Failure to randomize tmp", UVM_NONE);
                            end
                            for (int j = 0; j < WXDATA/8; j++) begin
                                for (int k = 0; k < 8; k++) begin
                                    m_tmp_data1[k+8*j] = tmp[k+8*j] & strb[i][j];
                                    m_tmp_data2[k+8*j] = data[i][k+8*j] & ~strb[i][j];
                                end
                            end
                            data[i]                                       = m_tmp_data1 | m_tmp_data2;
                        end
                        if (beat_count_of_req == SYS_nSysCacheline*8/WXDATA - 1) begin
                            beat_count_of_req = 0;
                        end
                        else begin
                            beat_count_of_req++;
                        end
                    end
                end
                m_ort[m_tmp_qA[0]].m_data = new[data.size()];
                m_ort[m_tmp_qA[0]].m_data = data;
            end
            else begin
                data = new[len + 1];
                foreach (data[i]) begin
                    axi_xdata_t tmp;
                    assert(std::randomize(tmp))
                    else begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), "Failure to randomize tmp", UVM_NONE);
                    end
                    data[i] = tmp;
                end
            end
        endfunction : give_data_for_ace_req

        task give_snoop_resp(axi_axaddr_t addr, axi_acsnoop_t acsnoop, output axi_crresp_t crresp, output axi_xdata_t cddata[]
            <%if(obj.wSecurityAttribute > 0){%>
                ,inout bit[<%=obj.wSecurityAttribute%>-1:0] security
            <%}%>);
            int                      cacheline_match_memupd_q[$];
            int                      m_tmp_q[$];
            ace_command_types_enum_t snptype;
            aceState_t               m_start_state;
            aceState_t               m_final_state;
            aceState_t               m_end_state;
            bit                      PassDirty, isShared, DataTransfer;
            axi_crresp_t             m_crresp;
            STT_struct_t             m_tmp_stt;
            bit                      m_upd_in_prog_snp_resp_is1pd0 = 0;
            bit                      is_dvm_sync_snp;
            bit                      is_last_part_dvm_snp;
            bit                      snpRspError;
	    int 		     m_outstanding_wrunq_wrlnunq_q[$];
	    bit 		     mem_upd_before_snp_comp_possible;

            cddata  = new[SYS_nSysCacheline*8/WCDDATA];
            snptype = convert_snp_type(acsnoop);
            if ($test$plusargs("snoop_bw_test")) begin
                crresp[CCRRESPDATXFERBIT]   = 1;
                crresp[CCRRESPERRBIT]       = 0;
                crresp[CCRRESPISSHAREDBIT]  = 1;
                crresp[CCRRESPPASSDIRTYBIT] = 0;
                crresp[CCRRESPWASUNIQUEBIT] = 0;
                foreach (cddata[i]) begin
                    cddata[i] = '1;
                end
                return;
            end
            //#Stimulus.IOAIU.SNPrsp.CMStatusAddrErr
            snpRspError = ($urandom_range(0,99) < prob_ace_snp_resp_error)? 1 : 0;

            if (snptype == DVMMSG ||
                snptype == DVMCMPL)begin
                crresp = 'b00000;
               if (snptype == DVMMSG) crresp[CCRRESPERRBIT] = snpRspError; // // AMBA protocol : A component is not permitted to set CRRESP to 0b00010 in response to a DVM Sync or a DVM Complete.// cf also axi_seq to remove error on DVM_SYNC
                //uvm_report_info($sformatf("ACE CACHE MODEL-DEBUG %s", get_full_name()), $sformatf("task:give_snoop_resp Responding to snoop for address 0x%0x security 0x%0x for snptype %1p from start state %1p to end state %1p with IsShared: %0d PassDirty: %0d DataTransfer: %0d UpdInProgress:%0d Error Inserted:%0d prob_ace_snp_resp_error:%0d", addr,
                //<%if(obj.wSecurityAttribute > 0){%>
                //    security,
                //<%}else{%>
                //    0,
                //<%}%>
                //snptype, m_start_state, m_final_state, crresp[CCRRESPISSHAREDBIT], crresp[CCRRESPPASSDIRTYBIT], crresp[CCRRESPDATXFERBIT], m_upd_in_prog_snp_resp_is1pd0, crresp[CCRRESPERRBIT], prob_ace_snp_resp_error), UVM_LOW); 

                return;
            end
            else begin
                //get current cache state
                m_start_state = current_cache_state(addr
                                                    <%if(obj.wSecurityAttribute > 0){%>
                                                        ,security
                                                    <%}%>);
                
                cacheline_match_memupd_q = {};
                cacheline_match_memupd_q = m_ort.find_first_index with ((item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]) && (item.m_security == security) && item.isUpdate);

                m_outstanding_wrunq_wrlnunq_q= {};
                m_outstanding_wrunq_wrlnunq_q = m_ort.find_first_index with ((item.isRead == 0) && (item.m_cmdtype inside  {WRLNUNQ, WRUNQ}) && item.isCohWriteSent);
                //if (m_outstanding_wrunq_wrlnunq_q.size() > 0) begin 
                //    `uvm_info("ORT_WRUNQ_WRLNUNQ", $sformatf("%0p", m_ort[m_outstanding_wrunq_wrlnunq_q[0]]), UVM_LOW);
                //end
                if (cacheline_match_memupd_q.size() > 0) begin
                    if (m_outstanding_wrunq_wrlnunq_q.size() > 0 && m_ort[cacheline_match_memupd_q[0]].isCohWriteSent) begin 
                        `uvm_error(get_full_name(), $sformatf("Fix inhouse ace_seq- MemUpd and WrUnq/WrLnUnq cannot be outstanding at the same time wr_cmdtype:%0s wr_addr:0x%0h memupd_cmdtype:%0s memupd_addr:0x%0h", m_ort[m_outstanding_wrunq_wrlnunq_q[0]].m_cmdtype.name, m_ort[m_outstanding_wrunq_wrlnunq_q[0]].m_addr, m_ort[cacheline_match_memupd_q[0]].m_cmdtype.name, m_ort[cacheline_match_memupd_q[0]].m_addr));
                    end
                    
                    //Complete any incoming snoop transactions without the use of WriteBack, WriteClean, WriteEvict, or Evict
                    //transactions while a WriteUnique or WriteLineUnique transaction is in progress
                    if (m_outstanding_wrunq_wrlnunq_q.size() > 0) begin 
                         mem_upd_before_snp_comp_possible = 0;
                    end 
                    //mem_upd has not made it to the native interface, either
                    //wait or respond immediately to the snoop
                    //this applies to EVCT too, since there is no data
                    //associated with it 
                    else if (!m_ort[cacheline_match_memupd_q[0]].isCohWriteSent || m_ort[cacheline_match_memupd_q[0]].m_cmdtype == EVCT)  begin
                         mem_upd_before_snp_comp_possible = $urandom_range(0,1);
                    end 
                    //D5.2.3 Memory Update in Progres
                    else if (m_ort[cacheline_match_memupd_q[0]].isCohWriteSent && m_ort[cacheline_match_memupd_q[0]].m_cmdtype inside {WRBK,WRCLN,WREVCT}) begin 
                         mem_upd_before_snp_comp_possible = 1; 
                    end 
                end
                
                //`uvm_info(get_full_name(), $sformatf("task:give_snoop_resp address 0x%0x security 0x%0x for snptype %1p - mem_upd_before_snp_comp_possible:%0d cacheline_match_memupd_q.size=%0d outstanding_wrunq_wrlnunq_q.size:%0d from start state %1p", addr, security,snptype, mem_upd_before_snp_comp_possible, cacheline_match_memupd_q.size(), m_outstanding_wrunq_wrlnunq_q.size(), m_start_state), UVM_LOW);

                if (mem_upd_before_snp_comp_possible) begin
                        bit m_resp_to_snoop_with_PD0_IS1;
                        
                      //  `uvm_info(get_full_name(), $sformatf("task:give_snoop_resp giving snoop for address 0x%0x security 0x%0x for snptype %1p. pending cacheline-match MemUpd -- cmdtype:%s, creation_time:%t, isCohWriteSent=%0b", addr, security, snptype, m_ort[cacheline_match_memupd_q[0]].m_cmdtype.name, m_ort[cacheline_match_memupd_q[0]].t_creation, m_ort[cacheline_match_memupd_q[0]].isCohWriteSent), UVM_LOW);
                        
                        // For the cases below, its not possible to respond with PD = 0 and IS = 1
                        if (m_start_state == ACE_IX) begin
                            m_resp_to_snoop_with_PD0_IS1 = 0;
                        end  
                        else if (snptype inside {RDUNQ, CLNINVL, MKINVL}) begin
                            m_resp_to_snoop_with_PD0_IS1 = 0;
                        end
                        else if ((snptype == CLNSHRD) && (m_start_state inside {ACE_UD, ACE_SD})) begin
                            m_resp_to_snoop_with_PD0_IS1 = 0;
                        end else begin 
                            m_resp_to_snoop_with_PD0_IS1 = ($urandom_range(1,100) > prob_respond_to_snoop_coll_with_wr) ? 0 : 1;
                        end

                        if (m_resp_to_snoop_with_PD0_IS1) begin
                            m_end_state                   = return_snoop_response_end_state(snptype, m_start_state, addr, m_crresp, snpRspError, 1);
                            m_upd_in_prog_snp_resp_is1pd0 = 1;
                            //`uvm_info(get_full_name(), $sformatf("task:give_snoop_resp addr:0x%0x ns:0x%0x for snptype:%1p start_state:%0p end_state:%0p responding immediately with pd0is1 while updreq is in progress", addr, security,snptype, m_start_state, m_end_state), UVM_LOW);
                        end
                        // wait till Update command is complete 
                        else begin
                            bit done = 0;
                            //`uvm_info(get_full_name(), $sformatf("task:give_snoop_resp giving snoop for address 0x%0x security 0x%0x for snptype %1p. waiting for Update command to be finished", addr, security, snptype), UVM_LOW);
                            do begin
                                @e_ort_delete;
                                m_tmp_q = {};
                                m_tmp_q = m_ort.find_first_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                                <%if(obj.wSecurityAttribute > 0){%>
                                    && item.m_security == security
                                <%}%>);
                                if ((m_tmp_q.size > 0) &&  
                                    ((m_ort[m_tmp_q[0]].m_cmdtype == WRNOSNP) || 
                                    (m_ort[m_tmp_q[0]].isUpdate && m_ort[m_tmp_q[0]].isCohWriteSent)
                                )
                                ) begin
                                    done = 0;
                                end
                                else begin
                                    done = 1;
                                end
                            end while (!done);

    			//    `uvm_info(get_full_name(), $sformatf("task:give_snoop_resp giving snoop for address 0x%0x security 0x%0x for snptype %1p. done waiting for Update command to be finished", addr,
                        //		<%if(obj.wSecurityAttribute > 0){%>
                        //    		security,
                        //		<%}else{%>
                        //    		0,
                        //		<%}%>
                        //	snptype), UVM_LOW);

                            // recalculating start state
                            m_start_state = current_cache_state(addr
                            <%if(obj.wSecurityAttribute > 0){%>
                                ,security
                            <%}%>);
                            m_end_state = return_snoop_response_end_state(snptype, m_start_state, addr, m_crresp, snpRspError, $urandom_range(1,100) > wt_keep_drty_cache_line_on_snps);
                        end
                end
                else begin
                    m_end_state = return_snoop_response_end_state(snptype, m_start_state, addr, m_crresp, snpRspError, $urandom_range(1,100) > wt_keep_drty_cache_line_on_snps);
                end

                isShared  = m_crresp[CCRRESPISSHAREDBIT];
                PassDirty = m_crresp[CCRRESPPASSDIRTYBIT];
                m_crresp[CCRRESPERRBIT] = snpRspError;
                crresp = m_crresp;

                if (crresp[CCRRESPDATXFERBIT]) begin
                    m_tmp_q = {};
                    m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                    <%if(obj.wSecurityAttribute > 0){%>
                        && item.m_security == security
                    <%}%>);
                    if (m_tmp_q.size() > 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: task:give_snoop_resp Found multiple copies of address 0x%0x in cache model in give snoop resp", addr), UVM_NONE);
                    end
                    else if (m_tmp_q.size() == 0) begin
                        <%if(obj.wSecurityAttribute > 0){%>
                            $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error:  task:give_snoop_resp Found no copies of address 0x%0x secure bit %0d in cache model even though DataXFer bit is set", addr, security), UVM_NONE);
                        <%}else{%>
                            $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: task:give_snoop_resp Found no copies of address 0x%0x in cache model even though DataXFer bit is set", addr), UVM_NONE);
                        <%}%>
                    end
                    else begin
                        int beat_count_of_req;
                        beat_count_of_req = addr[SYS_wSysCacheline-1:WLOGXDATA];
                        foreach (cddata[i]) begin
                            cddata[i] = m_cache[m_tmp_q[0]].m_data[beat_count_of_req];
                            if (beat_count_of_req == SYS_nSysCacheline*8/WXDATA - 1) begin
                                beat_count_of_req = 0;
                            end
                            else begin
                                beat_count_of_req++;
                            end
                        end
                    end
                end 

                // Save data in stt entry so we know what state to transition to once snoop response is sent
                m_tmp_stt.m_addr                                          = addr;
                <%if(obj.wSecurityAttribute > 0){%>
                    m_tmp_stt.m_security                                      = security;
                <%}%>
                m_tmp_stt.m_end_state                                     = m_end_state;
                m_tmp_stt.m_update_in_progress_and_responding_with_IS1PD0 = m_upd_in_prog_snp_resp_is1pd0;
                m_stt.push_back(m_tmp_stt);
                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                    ->e_cache_modify;
                <%}%>
                
                //----------------------------------------------------------------------- 
                // Changing state now to see if this works
                //----------------------------------------------------------------------- 
                m_tmp_q = {};
                m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                <%if(obj.wSecurityAttribute > 0){%>
                    && item.m_security == security
                <%}%>);
                if (m_tmp_q.size() > 1) begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In task:give_snoop_resp found multiple copies of address 0x%0x in cache model in modify cache line for snoop", addr), UVM_NONE);
                end
                if (m_end_state == ACE_IX) begin
                    if (m_tmp_q.size == 1) begin
                        m_cache.delete(m_tmp_q[0]);
                    end
                end
                else begin
                    if (m_tmp_q.size == 1) begin
                        if(!$cast(tmp_aceState, m_tmp_stt.m_end_state))
                            `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
                        m_cache[m_tmp_q[0]].m_state = tmp_aceState;
                    end
                end
                <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
                    ->e_cache_modify;
                <%}%>     

                m_final_state = current_cache_state(addr
                                                <%if(obj.wSecurityAttribute > 0){%>
                                                    ,security
                                                <%}%>);

                //----------------------------------------------------------------------- 
                //`uvm_info(get_full_name(), $sformatf("task:give_snoop_resp Responding to snoop for address 0x%0x security 0x%0x for snptype %1p from start state %1p to end state %1p with IsShared: %0d PassDirty: %0d DataTransfer: %0d UpdInProgress:%0d Error Inserted:%0d", addr,
                //<%if(obj.wSecurityAttribute > 0){%>
                //    security,
                //<%}else{%>
                //    0,
                //<%}%>
                //snptype, m_start_state, m_final_state, crresp[CCRRESPISSHAREDBIT], crresp[CCRRESPPASSDIRTYBIT], crresp[CCRRESPDATXFERBIT], m_upd_in_prog_snp_resp_is1pd0, crresp[CCRRESPERRBIT]), UVM_LOW); 
            end
            <% if(obj.COVER_ON) { %>
                  `ifndef FSYS_COVER_ON
                   <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                   cov.ace_snoop_response(snptype,m_start_state,m_final_state,crresp[CCRRESPISSHAREDBIT],crresp[CCRRESPPASSDIRTYBIT]);
                   <% } %>      
                  `endif 
              <%}%>
        endtask : give_snoop_resp

        // Call function below to give a start state based on weightage and 
        // check if there are any legal possible start state values
        function bit calculate_start_state(ace_command_types_enum_t cmdtype, output aceState_t start_state, input bit is_coh = 1);
            start_state_queue_t                              m_possible_start_states_array = new();
            state_queue_t                                    m_start_states_array;
            int                                              m_tmp_q[$];
            int                                              m_tmp_qA[$];
            int                                              m_tmp_indx_q[$];
            bit                                              success_expected_start_state = 0; 
            bit                                              success_legal_start_state = 0; 

            m_possible_start_states_array = return_legal_start_states(cmdtype); 
            m_tmp_indx_q = {};

            /*Loop through all the expected start states*/
            for (int i = 0; i < m_possible_start_states_array.m_start_state_queue_t[0].size(); i++) begin: _all_possible_start_states_loop_
                m_tmp_q = {};
                m_tmp_qA = {};
                if(!$cast(tmp_aceState, m_possible_start_states_array.m_start_state_queue_t[0][i]))
                    `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
                if((cmdtype inside {WRBK,WRCLN} && $test$plusargs("force_wb_wc_noncoh")) || (cmdtype ==WREVCT && $test$plusargs("force_we_noncoh")))
                begin
                    m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState && item.m_non_coherent_addr==1);
                end else begin
                    m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState);
                end

                foreach(m_tmp_qA[i]) begin
                    if (!is_coh) begin
                        if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 1) begin
                            if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                            <% if (obj.wSecurityAttribute > 0) { %>
                                ,m_cache[m_tmp_qA[i]].m_security
                            <% } %>
                            )) begin
                                m_tmp_q.push_back(m_tmp_qA[i]);
                            end
                        end //non_coherent_addr
                    end // is_coh=0
                    else if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 0) begin //coherent command and coherent address
                        if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                                ,m_cache[m_tmp_qA[i]].m_security
                        <% } %>                                                
                        )) begin
                            m_tmp_q.push_back(m_tmp_qA[i]);
                        end
                    end
                end
                
                if (m_tmp_q.size > 0) begin
                    success_expected_start_state = 1;
                end
                else begin
                    if (m_possible_start_states_array.m_start_state_queue_t[0][i] !== ACE_IX) begin
                        m_tmp_indx_q.push_back(i);
                    end
                    else begin
                        success_expected_start_state = 1;
                    end
                end
            end: _all_possible_start_states_loop_
            
            for (int i = m_tmp_indx_q.size() - 1; i >= 0; i--) begin
                m_possible_start_states_array.m_start_state_queue_t[0].delete(m_tmp_indx_q[i]);
            end
            if (success_expected_start_state) begin
                success_legal_start_state = 1;
            end
            
            m_tmp_indx_q = {};
            for (int i = 0; i < m_possible_start_states_array.m_start_state_queue_t[1].size(); i++) begin
                m_tmp_q = {};
                m_tmp_qA = {};
                if(!$cast(tmp_aceState, m_possible_start_states_array.m_start_state_queue_t[1][i]))
                    `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
            if((cmdtype inside {WRBK,WRCLN} && $test$plusargs("force_wb_wc_noncoh")) || (cmdtype ==WREVCT && $test$plusargs("force_we_noncoh"))) begin
                m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState && item.m_non_coherent_addr==1);
            end else begin
                m_tmp_qA = m_cache.find_index with (item.m_state == tmp_aceState);
                end
                foreach(m_tmp_qA[i]) begin
                    if (!is_coh) begin
                        if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 1) begin
                            if(cmdtype == RDNOSNP ||
                            cmdtype == WRNOSNP
                            ) begin
                                if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            ,m_cache[m_tmp_qA[i]].m_security
                                        <% } %>
                                    )) begin
                                m_tmp_q.push_back(m_tmp_qA[i]);
                                end
                            end else begin
                                if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                                    <% if (obj.wSecurityAttribute > 0) { %>
                                        ,m_cache[m_tmp_qA[i]].m_security
                                    <% } %>
                                )) begin
                                    m_tmp_q.push_back(m_tmp_qA[i]);
                                end
                            end
                        end
                    end
                    else if (m_cache[m_tmp_qA[i]].m_non_coherent_addr == 0) begin
                        if (check_if_addr_is_ok_to_send(cmdtype, m_cache[m_tmp_qA[i]].m_addr
                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                                ,m_cache[m_tmp_qA[i]].m_security
                            <% } %>                                                
                        )) begin
                            m_tmp_q.push_back(m_tmp_qA[i]);
                        end
                    end
                end
                if (m_tmp_q.size > 0) begin
                    success_legal_start_state = 1;
                end
                else begin
                    if (m_possible_start_states_array.m_start_state_queue_t[1][i] !== ACE_IX) begin
                        m_tmp_indx_q.push_back(i);
                    end
                    else begin
                        success_legal_start_state = 1;
                    end
                end
            end
            for (int i = m_tmp_indx_q.size() - 1; i >= 0; i--) begin
                m_possible_start_states_array.m_start_state_queue_t[1].delete(m_tmp_indx_q[i]);
            end

            // Cannot find a legal address in cache that can be sent with this cmdtype
            if ((success_expected_start_state || success_legal_start_state) == 0) begin
                return 0;
            end
            else begin
                if (wt_expected_start_state == 0) begin
                    if (success_legal_start_state) begin 
                        m_start_states_array = m_possible_start_states_array.m_start_state_queue_t[1];
                    end
                    else begin
                        m_start_states_array = m_possible_start_states_array.m_start_state_queue_t[0];
                    end
                end
                else if (wt_legal_start_state == 0) begin
                    if (success_expected_start_state) begin
                        m_start_states_array = m_possible_start_states_array.m_start_state_queue_t[0];
                    end
                    else begin
                        m_start_states_array = m_possible_start_states_array.m_start_state_queue_t[1];
                    end
                end
                else begin
                    randcase
                        success_expected_start_state && wt_expected_start_state : m_start_states_array = m_possible_start_states_array.m_start_state_queue_t[0];
                        success_legal_start_state    && wt_legal_start_state    : m_start_states_array = m_possible_start_states_array.m_start_state_queue_t[1];
                    endcase
                end

                m_start_states_array.shuffle();
                start_state = aceState_t'(m_start_states_array[0]);
                // For WrUnq, WrLnUnq, Rd*, Cln* and Mk* - use higher % of IX states
                if (cmdtype == WRUNQ ||
                    cmdtype == WRLNUNQ
                ) begin
                    if ($urandom_range(0,100) < prob_ace_wr_ix_start_state) begin
                        start_state = ACE_IX;
                    end
                end
                if (cmdtype == RDNOSNP      ||
                    cmdtype == RDONCE       ||
                    cmdtype == RDCLN        ||
                    cmdtype == RDNOTSHRDDIR ||
                    cmdtype == RDSHRD       ||
                    cmdtype == RDUNQ        || 
                    cmdtype == CLNSHRD      || 
                    cmdtype == MKUNQ
                ) begin
                    if ($urandom_range(0,100) < prob_ace_rd_ix_start_state) begin
                        start_state = ACE_IX;
                    end
                end
                return 1;
            end
        endfunction : calculate_start_state
    
        function bit calculate_is_coh(ace_command_types_enum_t cmdtype);
            bit is_coh = 0;
            ncore_memory_map m_mem = m_addr_mgr.get_memory_map_instance();

            <% if (obj.fnNativeInterface == "AXI4" || obj.useCache || obj.fnNativeInterface == "AXI5") { %>
                is_coh = 1;
            <% } %>
               
             
                if(cmdtype == RDNOSNP ||
                cmdtype == WRNOSNP
                ) begin
                    is_coh = 0;
                end
                //Ncore 3 doesn't support non-coherent STASH txn
                //FIXME: include RDONCEMAKEINVLD/RDONCECLNINVID
                else if(dii_cmo_test == 1         &&
                      ( cmdtype == CLNSHRDPERSIST ||
                        cmdtype == CLNSHRD        ||
                        cmdtype == CLNINVL        ||
                        cmdtype == MKINVL         )) begin
                        //to be able to send CMOs cmd to DII
                        is_coh = 0;
                end
                else if(
                    cmdtype == BARRIER ||
                    cmdtype == CLNSHRDPERSIST ||
                    cmdtype == CLNSHRD ||
                    cmdtype == CLNINVL ||
                    cmdtype == MKINVL) begin
                    if ($urandom_range(1,100) > prob_ace_coh_win_error) begin
                        is_coh = 1;
                    end else begin
                        is_coh = 0;
                    end
                end
                else if (
                    cmdtype == ATMLD   ||
                    cmdtype == ATMSTR  ||
                    cmdtype == ATMSWAP ||
                    cmdtype == ATMCOMPARE
                    ) begin
                    if ($test$plusargs("coherent_atomics")) begin
                        is_coh = 1;
                    end else begin
                        if (m_mem.noncoh_reg_maps_to_dii == 1) begin
                            `uvm_info("ATOMICS", $sformatf("There is no noncoh address region that maps to DMI in this config - hence force all atomics to be coherent"), UVM_DEBUG)
                            /*This implies that there is no noncoh address region that maps to DMI in this config*/
                            /*Since atomics can use only address region that maps to DMI, force all atomics to be coherent atomics */
                            is_coh = 1;
                        end else begin 
                            if ($urandom_range(1,100) > prob_ace_coh_win_error) begin
                                is_coh = 1;
                            end else begin
                                is_coh = 0;
                            end
                        end
                    end 
                end
                else begin
                    is_coh = 1;
                end
            
            
            //`uvm_info(get_full_name(), $sformatf("fn:calculate_is_coh cmdtype:%0p is_coh:%0d noncoh_reg_maps_to_dii_only:%0d", cmdtype, is_coh, m_mem.noncoh_reg_maps_to_dii), UVM_LOW)
            return is_coh;
        endfunction: calculate_is_coh
        // Call function below to give an end state based on weightage
        function aceState_t calculate_end_state(ace_command_types_enum_t cmdtype, aceState_t start_state, axi_axaddr_t addr, bit isShared = 0, bit PassDirty = 0);
            end_state_queue_t m_possible_end_states_array = new();
            state_queue_t     m_end_states_array;
            m_possible_end_states_array = return_legal_end_states(cmdtype, start_state, addr, isShared, PassDirty); 

            randcase
                wt_expected_end_state         : m_end_states_array = m_possible_end_states_array.m_end_state_queue_t[0];
                wt_legal_end_state_with_sf    : m_end_states_array = m_possible_end_states_array.m_end_state_queue_t[1];
                wt_legal_end_state_without_sf : m_end_states_array = m_possible_end_states_array.m_end_state_queue_t[2];
            endcase
            //`uvm_info("ACE CACHE MODEL", $sformatf("fn:calculate_end_state cmdtype:%0p start_state:%0p addr:0x%0h isShared:%0b PassDirty:%0b wt_expected_end_state:%0d wt_legal_end_state_with_sf:%0d wt_legal_end_state_without_sf:%0d m_end_states_array.size:%0d",cmdtype, start_state, addr, isShared, PassDirty, wt_expected_end_state,  wt_legal_end_state_with_sf, wt_legal_end_state_without_sf, m_end_states_array.size()), UVM_LOW);

            m_end_states_array.shuffle();
            calculate_end_state =aceState_t'(m_end_states_array[0]);
        endfunction : calculate_end_state

        // Function to convert snoop type from axi_acsnoop_t to ace_command_types_enum_t
        function ace_command_types_enum_t convert_snp_type(axi_acsnoop_t acsnoop);
            case (acsnoop)
                'b0000  : convert_snp_type = RDONCE;
                'b0001  : convert_snp_type = RDSHRD;
                'b0010  : convert_snp_type = RDCLN;
                'b0011  : convert_snp_type = RDNOTSHRDDIR;
                'b0111  : convert_snp_type = RDUNQ;
                'b1000  : convert_snp_type = CLNSHRD;
                'b1001  : convert_snp_type = CLNINVL;
                'b1101  : convert_snp_type = MKINVL;
                'b1110  : convert_snp_type = DVMCMPL;
                'b1111  : convert_snp_type = DVMMSG;
                default : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Undefined snoop type 0x%0x" , acsnoop), UVM_NONE);
            endcase
        endfunction : convert_snp_type

        function aceState_t current_cache_state(axi_axaddr_t addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                , inout bit[<%=obj.wSecurityAttribute%>-1:0] security
            <% } %>                                         
            );
            int m_tmp_q[$];
            m_tmp_q = m_cache.find_index with (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                && item.m_security == security
            <% } %>                                                
                        );
            if (m_tmp_q.size() > 1) begin
                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: In function current_cache_state found multiple copies of address 0x%0x in cache model in current cache state", addr), UVM_NONE);
            end
            else if (m_tmp_q.size() == 0) begin
                current_cache_state = ACE_IX;
            end
            else begin
                if(!$cast(current_cache_state, m_cache[m_tmp_q[0]].m_state))
                    `uvm_error("ACE CACHE MODEL", "Cast failed to temp state");
            end
        endfunction : current_cache_state

		//CONC-9720
		//ARM IHI 0022H.c ACE Spec D4.8.7 Restrictions on WriteUnique and WriteLineUnique usage
		//No additional WriteBack, WriteClean, WriteEvict, or Evict transactions can be issued until all outstanding WriteUnique or WriteLineUnique transactions are completed.
		//This function is called in axi_master_write_coh_seq-send_write_address
        function bit coh_upd_txn_ok_to_send();
        	int inflight_wr_q[$];
		    
			coh_upd_txn_ok_to_send = 1;
			inflight_wr_q = {};

    		foreach (m_ort[i]) begin
    		    if ((m_ort[i].isRead == 0) && (m_ort[i].m_cmdtype inside  {WRLNUNQ, WRUNQ}) && m_ort[i].isReqInFlight)
              	        `uvm_info("ACE CACHE MODEL - ORT", $sformatf("coh_upd_txn_ok_to_send - %0p", m_ort[i]), UVM_LOW);
                end

			inflight_wr_q = m_ort.find_index with ((item.isRead == 0) && (item.m_cmdtype inside  {WRLNUNQ, WRUNQ}) && item.isReqInFlight);
			if (inflight_wr_q.size() > 0) begin
				coh_upd_txn_ok_to_send = 0;
        	    `uvm_info("ACE CACHE MODEL", $sformatf("fn:txn_is_ok_to_send txn cannot be sent since outstanding wrunq/wrlineunq size:%0d", inflight_wr_q.size()), UVM_LOW)
			end
		endfunction:coh_upd_txn_ok_to_send
	
        //CONC-11840
	//ARM IHI 0022H.c ACE Spec C4.8.7 Restrictions on WriteUnique and WriteLineUnique usage
	//Complete any outstanding WriteBack, WriteClean, or WriteEvict or Evict transactions before issuing a WriteUnique or WriteLineUnique transaction.
	//This function is called in axi_master_write_noncoh_seq
        function bit wrunq_wrlnunq_txn_ok_to_send();
       	   int inflight_cohupd_wr_q[$];
	   wrunq_wrlnunq_txn_ok_to_send = 1;
	   inflight_cohupd_wr_q = {};

           //foreach (m_ort[i]) begin
           //	if (m_ort[i].isRead == 0)
           //	`uvm_info("ORT", $sformatf("noncoh_wrbk_wrcln_txn_ok_to_send - %0p", m_ort[i]), UVM_NONE);
           //end
           //prioritize MemUpds even if they are in the queue. only send WrUnq
           //if there are no MemUpd in the queue
	   inflight_cohupd_wr_q = m_ort.find_first_index with (!item.isRead && item.isUpdate && (item.m_cmdtype inside  {WRBK, WRCLN, WREVCT, EVCT} &&  (!item.isNonCoh)));
	   
           if (inflight_cohupd_wr_q.size() > 0) begin
	        wrunq_wrlnunq_txn_ok_to_send = 0;
               //`uvm_info("ACE CACHE MODEL", $sformatf("fn:txn_is_ok_to_send txn cannot be sent since outstanding wrbk/wrcln size:%0d", inflight_noncoh_wr_q.size()), UVM_LOW)
	   end 

	endfunction:wrunq_wrlnunq_txn_ok_to_send

        function bit check_if_addr_is_ok_to_send(ace_command_types_enum_t cmdtype, axi_axaddr_t addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                , bit[<%=obj.wSecurityAttribute%>-1:0] security
            <% } %>                                                
            );

            int m_addr_match_read_q[$];
            int m_addr_match_write_q[$];
            int m_addr_match_cmo_q[$];
            int m_addr_match_mem_upd_q[$];

            check_if_addr_is_ok_to_send = 0;

            //writes need to check to make there are no outstanding read to same cacheline address 
            //since the order of completion is undeterministic since they are independent channels.
            if (is_write_chnl_txn(cmdtype)) begin 
                m_addr_match_read_q = {};
                m_addr_match_read_q = m_ort.find_first_index with (item.isRead == 1 && !(item.m_cmdtype inside {DVMMSG, DVMCMPL}) && item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    && item.m_security == security
                <% } %>                                                
                );
            end
           
            //Refer Section 7.9 ACE Managers and CMOs
            //The Manager must complete any outstanding Shareable transactions, which permits the line to be allocated,
            //to a cache line before it issues a cache maintenance transaction to the same cache line./
            if (cmdtype inside {CLNSHRD, CLNINVL, MKINVL, CLNSHRDPERSIST}) begin 
                m_addr_match_read_q = {};
                m_addr_match_read_q = m_ort.find_first_index with (item.isRead == 1 && (item.m_cmdtype inside {RDONCE,RDNOSNP,RDUNQ,RDCLN,RDNOTSHRDDIR,RDSHRD,CLNUNQ,MKUNQ}) && item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    && item.m_security == security
                <% } %>                                                
                );
            end

            ////mem_upd txn should always wait for outstanding mem_upd txn to same cacheline address
             if (cmdtype inside {WRBK,WRCLN,WREVCT,EVCT}) begin
             m_addr_match_mem_upd_q = {}; 
              m_addr_match_mem_upd_q = m_ort.find_first_index with (item.isUpdate==1 && (item.m_cmdtype inside {WRBK,WRCLN,WREVCT,EVCT}) && item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    && item.m_security == security
                <% } %>                                                
                );
            
             end 

            //reads need to check to make there are no outstanding write to same cacheline address 
            //since the order of completion is undeterministic since they are independent channels
            if (is_read_chnl_txn(cmdtype)) begin 
                m_addr_match_write_q = {};
                m_addr_match_write_q = m_ort.find_first_index with (item.isRead == 0 && !(item.m_cmdtype inside {DVMMSG, DVMCMPL}) && item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    && item.m_security == security
                <% } %>                                                
                );
            end

            
            //writes needs to check to make sure there are no outstanding writes to same cacheline address 
            //since the order of completion is undeterministic unless they are same axid
            if (!$test$plusargs("axid_collision") && is_write_chnl_txn(cmdtype)) begin 
                m_addr_match_write_q = {};
                m_addr_match_write_q = m_ort.find_first_index with (item.isRead == 0 && !(item.m_cmdtype inside {DVMMSG, DVMCMPL}) && item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    && item.m_security == security
                <% } %>                                                
                );
            end
        
            //CONC-9697 BFM must not issue any transactions to the same cacheline address 
            //until there are no more outstanding cacheline-matching CMO 
            m_addr_match_cmo_q = {};
            m_addr_match_cmo_q = m_ort.find_first_index with (item.isRead == 1 &&
                                                (item.m_cmdtype inside {CLNSHRD, CLNINVL, MKINVL, CLNSHRDPERSIST}) &&
                                                (item.m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline])
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                                    && (item.m_security == security)
                <% } %>                                                
            );

            if (m_addr_match_read_q.size() == 0 && 
                m_addr_match_write_q.size() == 0 &&
                m_addr_match_cmo_q.size() == 0 &&
                m_addr_match_mem_upd_q.size() == 0
            ) begin
                check_if_addr_is_ok_to_send = 1;
            end else begin 
                `uvm_info(get_full_name(), $sformatf("fn:check_if_addr_is_ok_to_send:%0d ort_size:%0d cmdtype:%0s addr:0x%0h ns:%0b read_match:%0d write_match:%0d cmo_match:%0d", check_if_addr_is_ok_to_send, m_ort.size(), cmdtype, addr, security, m_addr_match_read_q.size, m_addr_match_write_q.size, m_addr_match_cmo_q.size), UVM_LOW)
                foreach (m_ort[i]) begin
                    if ((m_ort[i].m_addr[WAXADDR-1:SYS_wSysCacheline] == addr[WAXADDR-1:SYS_wSysCacheline]) &&
                        (m_ort[i].m_security == security) &&
                        !(m_ort[i].m_cmdtype inside {DVMMSG, DVMCMPL})) begin 
                        //`uvm_info("ORT_DBG_chk_if_addr_ok_to_send", $sformatf("idx:%0d %0p", i, m_ort[i]), UVM_LOW);
                    end
                end
            end 
        	
            
            //if (check_if_addr_is_ok_to_send == 0)
             //   `uvm_error(get_full_name(), $sformatf("fn:check_if_addr_is_ok_to_send End to debug"))

        endfunction : check_if_addr_is_ok_to_send

        //////////////////////////////////////////////////////////////////////////////////////////////

        ///////////////////////////////////////////////////////////////////////// 
        //
        // All the functions below reflect tables C4-1 to C4-29 in the ACE spec
        //
        ///////////////////////////////////////////////////////////////////////// 

        function end_state_queue_t return_legal_state_for_rd_no_snp(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOSNP Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX, ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOSNP Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX, ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOSNP Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOSNP Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX, ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_SD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOSNP Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_rd_no_snp

        function end_state_queue_t return_legal_state_for_rd_once(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDONCE Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDONCE Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDONCE Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDONCE Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                end
                ACE_SD: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDONCE Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_SD}; 
                    end
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_rd_once

        function end_state_queue_t return_legal_state_for_rd_cln(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDCLN Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDCLN Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDCLN Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDCLN Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                end
                ACE_SD: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDCLN Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_SD}; 
                    end
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_rd_cln

        function end_state_queue_t return_legal_state_for_rd_not_shrd_dir(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 1 && PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOTSHRDDIR Start State:%0s NotAllowed: IS:1 PD:1 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 0 && PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOTSHRDDIR Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOTSHRDDIR Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (isShared == 1 && PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOTSHRDDIR Start State:%0s NotAllowed: IS:1 PD:1 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 0 && PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                end
                ACE_SD: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDNOTSHRDDIR Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_SD}; 
                    end
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_rd_not_shrd_dir

        function end_state_queue_t return_legal_state_for_rd_shrd(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 0 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 0 && PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                    if (isShared == 1 && PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_SD}; 
                    end
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDSHRD Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDSHRD Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (isShared == 0 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 0 && PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1 && PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                    if (isShared == 1 && PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_SD}; 
                    end
                end
                ACE_SD: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDSHRD Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_SD}; 
                    end
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_rd_shrd

        function end_state_queue_t return_legal_state_for_rd_unq(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDUNQ Start State:%0s Expected: IS:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (isShared == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDUNQ Start State:%0s Expected: IS:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (PassDirty == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (PassDirty == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                    end
                end
                ACE_SD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (RDUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_rd_unq

        function end_state_queue_t return_legal_state_for_cln_unq(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_SD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_cln_unq

        function end_state_queue_t return_legal_state_for_cln_shrd(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNSHRD Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNSHRD Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC, ACE_UD,ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC, ACE_UD,ACE_SD}; 
                end
                ACE_UD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (CLNSHRD Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SC: 
                begin
                    if (PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNSHRD Start State:%0s Expected: PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    if (isShared == 0) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                    end
                    if (isShared == 1) begin
                        m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                        m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                    end
                end
                ACE_SD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (CLNSHRD Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_cln_shrd

        function end_state_queue_t return_legal_state_for_cln_invl(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (CLNINVL Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (CLNINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_UD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (CLNINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (CLNINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (CLNINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_cln_invl

        function end_state_queue_t return_legal_state_for_mk_unq(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (MKUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_UC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (MKUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_UD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (MKUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SC: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (MKUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
                ACE_SD: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (MKUNQ Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_UD}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_UD, ACE_SD}; 
                end
    
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_mk_unq

        function end_state_queue_t return_legal_state_for_mk_invl(aceState_t start_state, bit isShared, bit PassDirty, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    if (isShared == 1 || PassDirty == 1) begin
                        $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal IsShared/PassDirty value for request to address 0x%0x (MKINVL Start State:%0s Expected: IS:0 PD:0 Actual: IS:%0d PD:%0d)", addr, start_state, isShared, PassDirty), UVM_NONE);
                    end
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (MKINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_UD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (MKINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (MKINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (MKINVL Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_mk_invl

        function end_state_queue_t return_legal_state_for_wr_no_snp(aceState_t start_state, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UC: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_SC: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_SD: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_wr_no_snp

        function end_state_queue_t return_legal_state_for_wr_unq(aceState_t start_state, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UC: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRUNQ Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SC: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                end
                ACE_SD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRUNQ Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_wr_unq

        function end_state_queue_t return_legal_state_for_wr_ln_unq(aceState_t start_state, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UC: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                end
                ACE_UD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRLNUNQ Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SC: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                end
                ACE_SD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRLNUNQ Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_wr_ln_unq

        function end_state_queue_t return_legal_state_for_wr_bk(aceState_t start_state, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRBK Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_UC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRBK Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_UD: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_SC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRBK Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SD: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_wr_bk

        function end_state_queue_t return_legal_state_for_wr_cln(aceState_t start_state, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRCLN Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_UC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRCLN Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_UD: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                ACE_SC: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WRCLN Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SD: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_SC}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX, ACE_SC}; 
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_wr_cln

        function end_state_queue_t return_legal_state_for_wr_evct(aceState_t start_state, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            case (start_state)
                ACE_IX: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WREVCT Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_UC: 
                begin
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_UD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WREVCT Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
                ACE_SC: 
                begin
                    //WREVCT was issued from UC, but a SNPreq(like CleanShared), beat it and the line transitioned to SC  before the WREVCT completed. So initial state SC is valid too for WREVCT
                    m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
                    m_return_array.m_end_state_queue_t[2] = {ACE_IX}; 
                end
                ACE_SD: 
                begin
                    $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Illegal start state for request (WREVCT Start State:%0s) to address 0x%0x", start_state, addr), UVM_NONE);
                end
            endcase
            return m_return_array;
        endfunction : return_legal_state_for_wr_evct

        function end_state_queue_t return_legal_state_for_evct(aceState_t start_state, axi_axaddr_t addr);
            end_state_queue_t m_return_array = new();

            m_return_array.m_end_state_queue_t[0] = {ACE_IX}; 
            m_return_array.m_end_state_queue_t[1] = {ACE_IX}; 
            m_return_array.m_end_state_queue_t[2] = {}; 
            
            return m_return_array;
        endfunction : return_legal_state_for_evct

        // [0]: Expected Start states
        // [1]: Legal Start states
        function start_state_queue_t return_legal_start_states(ace_command_types_enum_t cmdtype);
            start_state_queue_t m_return_array = new();
    
            case (cmdtype)
                RDNOSNP      : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                RDONCE       : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                RDCLN        : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                RDNOTSHRDDIR : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                RDSHRD       : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                RDUNQ        : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                CLNUNQ       : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_SC, ACE_SD}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                CLNSHRD      : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                CLNSHRDPERSIST      : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                CLNINVL      : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX}; 
                end
                MKUNQ        : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX, ACE_SC, ACE_SD}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                MKINVL       : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX}; 
                end
                WRNOSNP      : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX, ACE_UC, ACE_UD}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_UD, ACE_SC, ACE_SD}; 
                end
                WRUNQ        : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                WRLNUNQ      : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_IX, ACE_UC, ACE_SC}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_IX, ACE_UC, ACE_SC}; 
                end
                WRBK         : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                end
                WRCLN        : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_UD, ACE_SD}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_UD, ACE_SD}; 
                end
                WREVCT       : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_UC}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_UC}; 
                end
                EVCT         : 
                begin
                    m_return_array.m_start_state_queue_t[0] = {ACE_UC, ACE_SC}; 
                    m_return_array.m_start_state_queue_t[1] = {ACE_UC, ACE_SC}; 
                end
            endcase

            return m_return_array;
        endfunction : return_legal_start_states

        // [0]: Expected End states
        // [1]: Legal End states with Snoop Filter
        // [2]: Legal End states without Snoop Filter
        function end_state_queue_t return_legal_end_states(ace_command_types_enum_t cmdtype, aceState_t start_state, axi_axaddr_t addr, bit isShared = 0, bit PassDirty = 0);
            end_state_queue_t m_return_array = new();

            //`uvm_info("ACE CACHE MODEL", $sformatf("fn:return_legal_end_states cmdtype:%0p start_state:%0p addr:0x%0h isShared:%0b PassDirty:%0b",cmdtype, start_state, addr, isShared, PassDirty), UVM_LOW);

            case (cmdtype)
                RDNOSNP      : m_return_array = return_legal_state_for_rd_no_snp(start_state, isShared, PassDirty, addr);
                RDONCE       : m_return_array = return_legal_state_for_rd_once(start_state, isShared, PassDirty, addr);
                RDCLN        : m_return_array = return_legal_state_for_rd_cln(start_state, isShared, PassDirty, addr);
                RDNOTSHRDDIR : m_return_array = return_legal_state_for_rd_not_shrd_dir(start_state, isShared, PassDirty, addr);
                RDSHRD       : m_return_array = return_legal_state_for_rd_shrd(start_state, isShared, PassDirty, addr);
                RDUNQ        : m_return_array = return_legal_state_for_rd_unq(start_state, isShared, PassDirty, addr);
                CLNUNQ       : m_return_array = return_legal_state_for_cln_unq(start_state, isShared, PassDirty, addr);
                CLNSHRD      : m_return_array = return_legal_state_for_cln_shrd(start_state, isShared, PassDirty, addr);
                CLNSHRDPERSIST  : m_return_array = return_legal_state_for_cln_shrd(start_state, isShared, PassDirty, addr);
                CLNINVL      : m_return_array = return_legal_state_for_cln_invl(start_state, isShared, PassDirty, addr);
                MKUNQ        : m_return_array = return_legal_state_for_mk_unq(start_state, isShared, PassDirty, addr);
                MKINVL       : m_return_array = return_legal_state_for_mk_invl(start_state, isShared, PassDirty, addr);
                WRNOSNP      : m_return_array = return_legal_state_for_wr_no_snp(start_state, addr);
                WRUNQ        : m_return_array = return_legal_state_for_wr_unq(start_state, addr);
                WRLNUNQ      : m_return_array = return_legal_state_for_wr_ln_unq(start_state, addr);
                WRBK         : m_return_array = return_legal_state_for_wr_bk(start_state, addr);
                WRCLN        : m_return_array = return_legal_state_for_wr_cln(start_state, addr);
                WREVCT       : m_return_array = return_legal_state_for_wr_evct(start_state, addr);
                EVCT         : m_return_array = return_legal_state_for_evct(start_state, addr);
                default      : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Unknown cmdtype %0s for address 0x%0x received", cmdtype.name(), addr), UVM_NONE);
            endcase

            return m_return_array;
        endfunction : return_legal_end_states

        //FIXME : change the name of the function to calculate CRRESP - sai
        function void calculate_IS_PD_DT(aceState_t start_state, aceState_t end_state, output axi_crresp_t m_crresp, input bit isMakeInvalid = 0);
            case (start_state)
                ACE_IX:
                begin
                    case (end_state)
                        ACE_IX:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 0;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        default : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Illegal state transition from start state %0p to end state %0p", start_state, end_state), UVM_NONE);
                    endcase
                    m_crresp[CCRRESPDATXFERBIT]   = 0;
                    m_crresp[CCRRESPWASUNIQUEBIT] = 0;
                end
                ACE_UC:
                begin
                    case (end_state)
                        ACE_IX:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 0;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        ACE_UC:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        ACE_SC:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        default : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Illegal state transition from start state %0p to end state %0p", start_state, end_state), UVM_NONE);
                    endcase
                    m_crresp[CCRRESPDATXFERBIT]   = ($urandom_range(1,100) > prob_dataxfer_snp_resp_on_clean_hit) ? 1'b0 : 1'b1;
                    m_crresp[CCRRESPWASUNIQUEBIT] = ($urandom_range(1,100) > prob_was_unique_snp_resp) ? 1'b0 : 1'b1;
                end
                ACE_UD:
                begin
                    case (end_state)
                        ACE_IX:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 0;
                            m_crresp[CCRRESPPASSDIRTYBIT] = (isMakeInvalid) ? $urandom_range(0,1) : 1;
                        end
                        ACE_UD:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        ACE_SC:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 1;
                        end
                        ACE_SD:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        default : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Illegal state transition from start state %0p to end state %0p", start_state, end_state), UVM_NONE);
                    endcase
                    m_crresp[CCRRESPDATXFERBIT]   = 1;
                    m_crresp[CCRRESPWASUNIQUEBIT] = ($urandom_range(1,100) > prob_was_unique_snp_resp) ? 1'b0 : 1'b1;
                end
                ACE_SC:
                begin
                    case (end_state)
                        ACE_IX:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 0;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        ACE_SC:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        default : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Illegal state transition from start state %0p to end state %0p", start_state, end_state), UVM_NONE);
                    endcase
                    m_crresp[CCRRESPDATXFERBIT]   = ($urandom_range(1,100) > prob_dataxfer_snp_resp_on_clean_hit) ? 1'b0 : 1'b1;
                    m_crresp[CCRRESPWASUNIQUEBIT] = 0;
                end
                ACE_SD:
                begin
                    case (end_state)
                        ACE_IX:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 0;
                            m_crresp[CCRRESPPASSDIRTYBIT] = (isMakeInvalid) ? $urandom_range(0,1) : 1;
                        end
                        ACE_SC:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 1;
                        end
                        ACE_SD:
                        begin
                            m_crresp[CCRRESPISSHAREDBIT]  = 1;
                            m_crresp[CCRRESPPASSDIRTYBIT] = 0;
                        end
                        default : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Illegal state transition from start state %0p to end state %0p", start_state, end_state), UVM_NONE);
                    endcase
                    m_crresp[CCRRESPDATXFERBIT]   = 1;
                    m_crresp[CCRRESPWASUNIQUEBIT] = 0;
                end
            endcase
            if(val_was_unique_always0_snp_resp) m_crresp[CCRRESPWASUNIQUEBIT] = 0;
        endfunction : calculate_IS_PD_DT 

        function aceState_t return_legal_snoop_state_for_rd_once(aceState_t start_state, axi_axaddr_t addr, output axi_crresp_t m_crresp, input bit snpRspError, input bit isPD0IS1);
            aceState_t m_end_state;
            int        wt_tmp_lose_cache_line_on_snps;

            wt_tmp_lose_cache_line_on_snps = (!isPD0IS1) ? wt_lose_cache_line_on_snps : 0;
                    case (start_state)
                    ACE_IX : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UC : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_UC; 
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                    ACE_UD : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1               : m_end_state = ACE_UD; 
                                    (1 & !isPD0IS1) : m_end_state = ACE_SC; 
                                    1               : m_end_state = ACE_SD; 
                                endcase
                            end
                        endcase
                    end
                    ACE_SC : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                    ACE_SD : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    (1 & !isPD0IS1) : m_end_state = ACE_SC; 
                                    1               : m_end_state = ACE_SD; 
                                endcase
                            end
                        endcase
                    end
                endcase
            calculate_IS_PD_DT(start_state, m_end_state, m_crresp);
            return m_end_state;
        endfunction : return_legal_snoop_state_for_rd_once

        function aceState_t return_legal_snoop_state_for_rd_shrd(aceState_t start_state, axi_axaddr_t addr, output axi_crresp_t m_crresp, input bit snpRspError, input bit isPD0IS1);
            aceState_t m_end_state;
            int        wt_tmp_lose_cache_line_on_snps;

            wt_tmp_lose_cache_line_on_snps = (!isPD0IS1) ? wt_lose_cache_line_on_snps : 0;

                case (start_state)
                    ACE_IX : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UC : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                    ACE_UD : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    (1 & !isPD0IS1) : m_end_state = ACE_SC; 
                                    1               : m_end_state = ACE_SD; 
                                endcase
                            end
                        endcase
                    end
                    ACE_SC : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                    ACE_SD : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    (1 & !isPD0IS1) : m_end_state = ACE_SC; 
                                    1               : m_end_state = ACE_SD; 
                                endcase
                            end
                        endcase
                    end
                endcase
            calculate_IS_PD_DT(start_state, m_end_state, m_crresp);
            return m_end_state;
        endfunction : return_legal_snoop_state_for_rd_shrd

        function aceState_t return_legal_snoop_state_for_rd_unq(aceState_t start_state, axi_axaddr_t addr, output axi_crresp_t m_crresp, input bit snpRspError, input bit isPD0IS1);
            aceState_t m_end_state;

            if (isPD0IS1) begin
                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Snoop received of type RDUNQ for address 0x%0x where PD=0 IS=1 is expected, but not possible based on initial state %0p", addr, start_state), UVM_NONE);
            end
                case (start_state)
                    ACE_IX : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UC : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UD : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_SC : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_SD : 
                    begin
                        m_end_state = ACE_IX;
                    end
                endcase
            calculate_IS_PD_DT(start_state, m_end_state, m_crresp);
            return m_end_state;
        endfunction : return_legal_snoop_state_for_rd_unq

        function aceState_t return_legal_snoop_state_for_cln_invl(aceState_t start_state, axi_axaddr_t addr, output axi_crresp_t m_crresp, input bit snpRspError, input bit isPD0IS1);
            aceState_t m_end_state;

            if (isPD0IS1) begin
                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Snoop received of type CLNINVL for address 0x%0x where PD=0 IS=1 is expected, but not possible based on initial state %0p", addr, start_state), UVM_NONE);
            end
                case (start_state)
                    ACE_IX : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UC : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UD : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_SC : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_SD : 
                    begin
                        m_end_state = ACE_IX;
                    end
                endcase
            calculate_IS_PD_DT(start_state, m_end_state, m_crresp);
            return m_end_state;
        endfunction : return_legal_snoop_state_for_cln_invl


        function aceState_t return_legal_snoop_state_for_mk_invl(aceState_t start_state, axi_axaddr_t addr, output axi_crresp_t m_crresp, input bit snpRspError, input bit isPD0IS1);
            aceState_t m_end_state;

            if (isPD0IS1) begin
                $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("TB Error: Snoop received of type MKINVL for address 0x%0x where PD=0 IS=1 is expected, but not possible based on initial state %0p", addr, start_state), UVM_NONE);
            end
                case (start_state)
                    ACE_IX : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UC : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UD : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_SC : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_SD : 
                    begin
                        m_end_state = ACE_IX;
                    end
                endcase
            calculate_IS_PD_DT(start_state, m_end_state, m_crresp, 1);
            return m_end_state;
        endfunction : return_legal_snoop_state_for_mk_invl

        function aceState_t return_legal_snoop_state_for_cln_shrd(aceState_t start_state, axi_axaddr_t addr, output axi_crresp_t m_crresp, input bit snpRspError, input bit isPD0IS1);
            aceState_t m_end_state;
            int                                   wt_tmp_lose_cache_line_on_snps;

            wt_tmp_lose_cache_line_on_snps = (!isPD0IS1) ? wt_lose_cache_line_on_snps : 0;
                case (start_state)
                    ACE_IX : 
                    begin
                        m_end_state = ACE_IX;
                    end
                    ACE_UC : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_UC; 
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                    ACE_UD : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                    ACE_SC : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                    ACE_SD : 
                    begin
                        randcase
                            wt_tmp_lose_cache_line_on_snps : m_end_state = ACE_IX; 
                            (100 - wt_tmp_lose_cache_line_on_snps)       : 
                            begin
                                randcase
                                    1 : m_end_state = ACE_SC; 
                                endcase
                            end
                        endcase
                    end
                endcase
            calculate_IS_PD_DT(start_state, m_end_state, m_crresp);
            return m_end_state;
        endfunction : return_legal_snoop_state_for_cln_shrd

        function aceState_t return_snoop_response_end_state(ace_command_types_enum_t snptype, aceState_t start_state, axi_axaddr_t addr, output axi_crresp_t m_crresp, input bit snpRspError, input bit isPD0IS1 = 0);

            case (snptype)
                RDONCE       : return_snoop_response_end_state = return_legal_snoop_state_for_rd_once(start_state, addr, m_crresp, snpRspError, isPD0IS1); 
                RDCLN,
                RDSHRD,
                RDNOTSHRDDIR : return_snoop_response_end_state = return_legal_snoop_state_for_rd_shrd(start_state, addr, m_crresp, snpRspError, isPD0IS1); 
                RDUNQ        : return_snoop_response_end_state = return_legal_snoop_state_for_rd_unq(start_state, addr, m_crresp, snpRspError, 0); 
                CLNINVL      : return_snoop_response_end_state = return_legal_snoop_state_for_cln_invl(start_state, addr, m_crresp, snpRspError, 0); 
                MKINVL       : return_snoop_response_end_state = return_legal_snoop_state_for_mk_invl(start_state, addr, m_crresp, snpRspError, 0); 
                CLNSHRD      : return_snoop_response_end_state = return_legal_snoop_state_for_cln_shrd(start_state, addr, m_crresp, snpRspError, isPD0IS1); 
                default : uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("Unknown snptype %0s for address 0x%0x received", snptype, addr), UVM_NONE);
            endcase
        endfunction : return_snoop_response_end_state

    endclass : ace_cache_model 

<%}%>

////////////////////////////////////////////////////////////////////////////////
//
// AXI Memory Model
//
////////////////////////////////////////////////////////////////////////////////


class axi_memory_model extends uvm_object;

    bit [(SYS_nSysCacheline*8)-1:0] m_memory [axi_axaddr_security_t];
 
    `uvm_object_param_utils(axi_memory_model)
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_memory_model");
        super.new(name);
    endfunction : new


    ///////////////////////////////////////////////////////////////////////// 
    // If userData = 0, function will preload addr[32+cacheline offset - 1:cacheline offset -1] 
    // zero extended if required and stamp this every 32 bits for that address
    // If user wants to preload memory with other data, user will set userData = 1 
    // and the address is required to be cacheline aligned (bits lower than cacheline offset should be 0)
    ///////////////////////////////////////////////////////////////////////// 

    function bit preload_memory(axi_axaddr_security_t addr, bit userData = 0, bit [(SYS_nSysCacheline*8)-1:0] data = '0);
        bit [(SYS_nSysCacheline*8)-1:0] m_data; 
        if (!m_memory.exists(addr)) begin
            if (!userData) begin
                bit [31:0] m_tmp_data;
                if($test$plusargs("axi_mem_init_0")) begin
		   m_tmp_data = 'h0;
		end else begin
                   m_tmp_data = ((addr >> SYS_wSysCacheline) & 32'hffff_ffff);
		end	       
                for (int i = 0; i < SYS_nSysCacheline * 8; i = i + 32) begin
                    <%if (obj.Block === 'dmi') { %>
                    if($test$plusargs("axi_mem_init_0")) begin
		       m_tmp_data = 'h0;
		    end else begin
                       m_tmp_data = $urandom();
		    end	       
                    <% } %>
                    m_data[i +: 32] = m_tmp_data[31:0];
                end
            end
            else begin
                m_data = data;
            end
	    `uvm_info(get_full_name(), $sformatf("preload_memory: m_memory[0x%0h] = 0x%0h", addr, m_data), UVM_MEDIUM)
            m_memory[addr] = m_data;
            return 1;
        end
        else begin
            return 0;
        end
    endfunction : preload_memory

    ///////////////////////////////////////////////////////////////////////// 
    // If read access is for something less or more than a cacheline, the memory
    // model just sends random data
    // Only returns data for WRAP type
    ///////////////////////////////////////////////////////////////////////// 

    function void read_data(axi_axaddr_security_t addr, axi_axlen_t len, axi_axsize_t size, output axi_xdata_t data[], input axi_axburst_t burst=AXIINCR);
        bit m_is_cacheline_access;

        data = new [len + 1];

        // Checking to see if this is a cacheline access
        if (2**size * (len+1) !== SYS_nSysCacheline) begin
            m_is_cacheline_access = 0;
        end
        else begin
            m_is_cacheline_access = 1; 
        end
        if (!m_is_cacheline_access) begin
            axi_axaddr_security_t m_cache_aligned_addr = ((addr >> SYS_wSysCacheline) << (SYS_wSysCacheline));
            axi_xdata_t tmp;

           if (!m_memory.exists(m_cache_aligned_addr)) begin
              uvm_report_info("AXI MEM MODEL", $sformatf("read_data - non full cacheline read.  Cacheline address 0x%0x, no existing data", m_cache_aligned_addr), UVM_DEBUG);
              foreach (data[i]) begin 
	         if($test$plusargs("axi_mem_init_0")) begin
                    data[i] = 0;
                 end 
	         else begin
                    assert(std::randomize(tmp))
                    else begin
                       $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), "Failure to randomize tmp", UVM_NONE);
                    end
		    data[i] = tmp;
                 end
	      end // foreach (data[i])
	   end
           else begin
              if ($test$plusargs("axi_mem_random_non_cacheline_read_dis")) begin
                 axi_xdata_t           m_tmp_data[];
                 axi_xdata_t           m_data_mask;
                 int                                              beat_count_of_req;
                 int addr_offset, align_addr_offset, axi_bus_offset, axi_bus_aligned_offset, packet_num;

                 uvm_report_info("AXI MEM MODEL", $sformatf("read_data - non full cacheline read.  Cacheline address 0x%0x, existing data 0%0x", m_cache_aligned_addr, m_memory[m_cache_aligned_addr]), UVM_DEBUG);
                 //uvm_report_info("AXI MEM MODEL", $sformatf("DEBUG read_data - non full cacheline read. WLOGXDATA %0d SYS_nSysCacheline %0d SYS_wSysCacheline %0d", WLOGXDATA,SYS_nSysCacheline,SYS_wSysCacheline), UVM_LOW);
                 m_data_mask   = '1;
                 m_tmp_data    = new[len + 1];
                 //m_tmp_data    = new[(SYS_nSysCacheline*8)/(2**size*8)];
                 addr_offset = addr[SYS_wSysCacheline-1:0];
                 align_addr_offset = ((addr_offset >> (size)) << (size)) * 8;
                 axi_bus_offset = addr[WLOGXDATA-1 : 0];
                 axi_bus_aligned_offset = ((axi_bus_offset >> (size)) << (size)) * 8;

                 //uvm_report_info("AXI MEM MODEL", $sformatf("DEBUG read_data - addr_offset %0d,align_addr_offset %0d,axi_bus_offset %0d,axi_bus_aligned_offset %0d",addr_offset,align_addr_offset,axi_bus_offset,axi_bus_aligned_offset), UVM_LOW);
                 if (!m_memory.exists(m_cache_aligned_addr)) begin
                     preload_memory(m_cache_aligned_addr);
                     uvm_report_info("AXI MEM MODEL", $sformatf("read_data - Address 0x%0x does not exist in mem model. Preloading", m_cache_aligned_addr), UVM_LOW);
                 end
                 // Setting up m_tmp_data to break down cache line data without critical word first
                 // Notes: If size < xdata width, I am setting up all chunks within xdata to have the 
                 // same data. For ex, if we have a 64B cacheline, 16B data bus width and size is 2B, 
                 // then we send 32 chunks of data. 0-7 chunks have the same data cacheline[0], 
                 // 8-15 has cacheline[1] etc... 
                 foreach (m_tmp_data[i]) begin
                         bit [511:0] m_tmp_1;
                         int         m_tmp_2;
                         int         m_tmp_3;
                         if(i==0) packet_num = 0;
                         m_tmp_2       = align_addr_offset + (packet_num*2**size*8);
                         m_cache_aligned_addr = (m_tmp_2>=(SYS_nSysCacheline*8))? (m_cache_aligned_addr + SYS_nSysCacheline) : m_cache_aligned_addr;  // In case of cache line change
                         align_addr_offset    = (m_tmp_2>=(SYS_nSysCacheline*8))? 0 : align_addr_offset;  // In case of cache line change
                         m_tmp_3              = (m_tmp_2>=(SYS_nSysCacheline*8))? m_tmp_2 : m_tmp_3;  // In case of cache line change
                         m_tmp_2              =  m_tmp_2 - m_tmp_3; // In case of cache line change
                         if (axi_axburst_enum_t'(burst) == AXIWRAP) begin
                             if(m_tmp_2==0 && i>0) begin // In case of cacheline change or wrap
                               m_cache_aligned_addr = m_cache_aligned_addr - SYS_nSysCacheline; // Same cacheline
                               packet_num = 0;
                             end
                         end else if (axi_axburst_enum_t'(burst) == AXIINCR) begin
                             if(m_tmp_2==0 && i>0) begin // In case of cacheline change or wrap
                               m_cache_aligned_addr = m_cache_aligned_addr; // cacheline change as done above
                               packet_num = 0;
                             end
                         end
                         if (!m_memory.exists(m_cache_aligned_addr)) begin
                            preload_memory(m_cache_aligned_addr);
                            uvm_report_info("AXI MEM MODEL", $sformatf("read_data - Address 0x%0x does not exist in mem model. Preloading", m_cache_aligned_addr), UVM_LOW);
                         end
                         m_tmp_1       = ((m_memory[m_cache_aligned_addr] >> m_tmp_2) << axi_bus_aligned_offset) & (m_data_mask);
                         data[i]       = m_tmp_1;
                         axi_bus_aligned_offset = ((axi_bus_aligned_offset + (2**size*8))> ((2**WLOGXDATA*8) - 1)) ? 0 : (axi_bus_aligned_offset + (2**size*8));
                         //uvm_report_info("AXI MEM MODEL", $sformatf("DEBUG read_data - i %0d m_tmp_2 %0d m_tmp_1 0x%0x m_data_mask 0x%0x len %0d size %0d part1 0x%0x axi_bus_aligned_offset %0d m_tmp_3 %0d",i, m_tmp_2,m_tmp_1,m_data_mask,len,size,(m_memory[m_cache_aligned_addr] >> m_tmp_2),axi_bus_aligned_offset,m_tmp_3), UVM_LOW);
                         packet_num = packet_num + 1;
                 end
                 foreach (m_tmp_data[i]) begin
                     `uvm_info("AXI MEM MODEL", $sformatf("read_data - cacheline address 0x%0h offset %0d : data 0x%0h", addr, i, m_tmp_data[i]), UVM_LOW);
                 end
                 // Applying critical word first
                 //beat_count_of_req = addr[SYS_wSysCacheline-1:WLOGXDATA];
                 //for (int i = 0; i < len + 1; i++) begin
                 //   data[i] = m_tmp_data[beat_count_of_req];
                 //   uvm_report_info("AXI MEM MODEL", $sformatf("read_data - Beat %0d data[%0d] = 0x%0x", beat_count_of_req, i, data[i]), UVM_LOW);
                 //   if (beat_count_of_req == SYS_nSysCacheline*8/WXDATA - 1) begin
                 //      beat_count_of_req = 0;
                 //   end
                 //   else begin
                 //      beat_count_of_req++;
                 //   end
                 //end
              end
	      else begin
                 foreach (data[i]) begin 
                    assert(std::randomize(tmp))
                    else begin
                       $stacktrace();uvm_report_error($sformatf("ACE CACHE MODEL%s", get_full_name()), "Failure to randomize tmp", UVM_NONE);
                    end
                    `uvm_info("AXI MEM MODEL", $sformatf("read_data - non cacheline address 0x%0h offset %0d : data 0x%0h", addr, i, tmp), UVM_DEBUG);
                    data[i] = tmp;
		 end
              end // else: !if($test$plusargs("axi_mem_random_non_cacheline_read_dis"))
           end // else: !if(!m_memory.exists(m_cache_aligned_addr))
        end // if (!m_is_cacheline_access)
        else begin
            axi_axaddr_security_t m_cache_aligned_addr = ((addr >> SYS_wSysCacheline) << (SYS_wSysCacheline));
            axi_xdata_t           m_tmp_data[];
            axi_xdata_t           m_data_mask;
            int                                              beat_count_of_req;
            int addr_offset, align_addr_offset, axi_bus_offset, axi_bus_aligned_offset, packet_num;

            if(m_cache_aligned_addr != addr) begin
               uvm_report_info("AXI MEM MODEL", $sformatf("read_data - Aligning address 0x%0x to cache-aligned address 0%0x", addr, m_cache_aligned_addr), UVM_DEBUG);
            end
            //uvm_report_info("AXI MEM MODEL", $sformatf("DEBUG read_data - full cacheline read. WLOGXDATA %0d SYS_nSysCacheline %0d SYS_wSysCacheline %0d", WLOGXDATA,SYS_nSysCacheline,SYS_wSysCacheline), UVM_LOW);
            m_data_mask   = '1;
            m_tmp_data    = new[len + 1];
            //m_tmp_data    = new[(SYS_nSysCacheline*8)/(2**size*8)];
            addr_offset = addr[SYS_wSysCacheline-1:0];
            align_addr_offset = ((addr_offset >> (size)) << (size)) * 8;
            axi_bus_offset = addr[WLOGXDATA-1 : 0];
            axi_bus_aligned_offset = ((axi_bus_offset >> (size)) << (size)) * 8;

            //uvm_report_info("AXI MEM MODEL", $sformatf("DEBUG read_data - addr_offset %0d,align_addr_offset %0d,axi_bus_offset %0d,axi_bus_aligned_offset %0d",addr_offset,align_addr_offset,axi_bus_offset,axi_bus_aligned_offset), UVM_LOW);
            if (!m_memory.exists(m_cache_aligned_addr)) begin
                preload_memory(m_cache_aligned_addr);
                //uvm_report_info("AXI MEM MODEL", $sformatf("read_data - Address 0x%0x does not exist in mem model. Preloading", m_cache_aligned_addr), UVM_LOW);
            end
            // Setting up m_tmp_data to break down cache line data without critical word first
            // Notes: If size < xdata width, I am setting up all chunks within xdata to have the 
            // same data. For ex, if we have a 64B cacheline, 16B data bus width and size is 2B, 
            // then we send 32 chunks of data. 0-7 chunks have the same data cacheline[0], 
            // 8-15 has cacheline[1] etc... 
            foreach (m_tmp_data[i]) begin
                    bit [511:0] m_tmp_1;
                    int         m_tmp_2;
                    int         m_tmp_3;
                    if(i==0) packet_num = 0;
                    m_tmp_2       = align_addr_offset + (packet_num*2**size*8);
                    m_cache_aligned_addr = (m_tmp_2>=(SYS_nSysCacheline*8))? (m_cache_aligned_addr + SYS_nSysCacheline) : m_cache_aligned_addr;  // In case of cache line change
                    align_addr_offset    = (m_tmp_2>=(SYS_nSysCacheline*8))? 0 : align_addr_offset;  // In case of cache line change
                    m_tmp_3              = (m_tmp_2>=(SYS_nSysCacheline*8))? m_tmp_2 : m_tmp_3;  // In case of cache line change
                    m_tmp_2              =  m_tmp_2 - m_tmp_3; // In case of cache line change
                    if (axi_axburst_enum_t'(burst) == AXIWRAP) begin
                        if(m_tmp_2==0 && i>0) begin // In case of cacheline change or wrap
                          m_cache_aligned_addr = m_cache_aligned_addr - SYS_nSysCacheline; // Same cacheline
                          packet_num = 0;
                        end
                    end else if (axi_axburst_enum_t'(burst) == AXIINCR) begin
                        if(m_tmp_2==0 && i>0) begin // In case of cacheline change or wrap
                          m_cache_aligned_addr = m_cache_aligned_addr; // cacheline change as done above
                          packet_num = 0;
                        end
                    end
                    if (!m_memory.exists(m_cache_aligned_addr)) begin
                       preload_memory(m_cache_aligned_addr);
                       uvm_report_info("AXI MEM MODEL", $sformatf("read_data - Address 0x%0x does not exist in mem model. Preloading", m_cache_aligned_addr), UVM_LOW);
                    end
                    m_tmp_1       = ((m_memory[m_cache_aligned_addr] >> m_tmp_2) << axi_bus_aligned_offset) & (m_data_mask);
                    data[i]       = m_tmp_1;
                    axi_bus_aligned_offset = ((axi_bus_aligned_offset + (2**size*8))> ((2**WLOGXDATA*8) - 1)) ? 0 : (axi_bus_aligned_offset + (2**size*8));
                    //uvm_report_info("AXI MEM MODEL", $sformatf("DEBUG read_data - i %0d m_tmp_2 %0d m_tmp_1 0x%0x m_data_mask 0x%0x len %0d size %0d part1 0x%0x axi_bus_aligned_offset %0d m_tmp_3 %0d",i, m_tmp_2,m_tmp_1,m_data_mask,len,size,(m_memory[m_cache_aligned_addr] >> m_tmp_2),axi_bus_aligned_offset,m_tmp_3), UVM_LOW);
                    packet_num = packet_num + 1;
            end
            foreach (m_tmp_data[i]) begin
                `uvm_info("AXI MEM MODEL", $sformatf("read_data - cacheline address 0x%0h offset %0d : data 0x%0h", addr, i, m_tmp_data[i]), UVM_DEBUG);
            end
            //// Applying critical word first
            //beat_count_of_req = addr[SYS_wSysCacheline-1:WLOGXDATA];
            //for (int i = 0; i < len + 1; i++) begin
            //    data[i] = m_tmp_data[beat_count_of_req];
            //    if (beat_count_of_req == SYS_nSysCacheline*8/WXDATA - 1) begin
            //        beat_count_of_req = 0;
            //    end
            //    else begin
            //        beat_count_of_req++;
            //    end
            //    uvm_report_info("AXI MEM MODEL", $sformatf("read_data - Beat %0d data[%0d] = 0x%0x", beat_count_of_req, i, data[i]), UVM_LOW);
            //end
        end
    endfunction : read_data

    ///////////////////////////////////////////////////////////////////////// 
    // If write access is for something more than a cacheline, the memory
    // model does not get updated. Narrow transfers not supported 
    ///////////////////////////////////////////////////////////////////////// 

    function void write_data(axi_axaddr_security_t addr, axi_axlen_t len, axi_axsize_t size, axi_axburst_t burst, axi_xdata_t data[], axi_xstrb_t strb[]);
        bit                                                    m_is_cacheline_access;
        bit [SYS_wSysCacheline-1:0] m_offset_mask;
        axi_axaddr_security_t data_size_aligned_addr = (addr >> WLOGXDATA) << WLOGXDATA;
        bit [511:0] m_tmp_1;
        int         m_tmp_2;
        int addr_offset, align_addr_offset, axi_bus_offset, axi_bus_aligned_offset, packet_num;

        m_offset_mask = '1;

        // Checking to see if this is a cacheline access
        if (axi_axburst_enum_t'(burst) == AXIINCR) begin
            if ((2**size * (len + 1) + (data_size_aligned_addr & m_offset_mask)) > SYS_nSysCacheline) begin
                m_is_cacheline_access = 0;
            end
            else begin
                m_is_cacheline_access = 1; 
            end
        end
        else if (axi_axburst_enum_t'(burst) == AXIWRAP) begin
            if ((2**size * (len + 1)) > SYS_nSysCacheline) begin
                m_is_cacheline_access = 0;
            end
            else begin
                m_is_cacheline_access = 1; 
            end
        end
        if (2**size*8 !== WXDATA) begin
            m_is_cacheline_access = 0;
        end
        if ((!m_is_cacheline_access) && (!$test$plusargs("axi_mem_non_cacheline_write_en"))) begin
            return;
        end
        else begin
            axi_axaddr_security_t m_cache_aligned_addr = ((addr >> SYS_wSysCacheline) << (SYS_wSysCacheline));
            bit [(SYS_nSysCacheline*8)-1:0] m_data, m_data1; 
            bit [SYS_wSysCacheline-1:0]     m_offset;
            int                                                        m_beat_offset;
            int                                                        m_beat_offset_counter;
            //bit                                                        is_data_capture_done = 0;

            if (m_memory.exists(m_cache_aligned_addr)) begin
                m_data = m_memory[m_cache_aligned_addr]; 
            end
            else begin
                m_data = '0;
            end
            m_offset    = data_size_aligned_addr & m_offset_mask;
            m_beat_offset = m_offset >> WLOGXDATA; 
            if (burst == AXIWRAP) begin
                case (len)
                    1: m_beat_offset_counter = m_beat_offset[0]; 
                    3: m_beat_offset_counter = m_beat_offset[1:0]; 
                    7: m_beat_offset_counter = m_beat_offset[2:0]; 
                    15: m_beat_offset_counter = m_beat_offset[3:0]; 
                endcase
            end else begin
                m_beat_offset_counter = 0;
            end
 
            //uvm_report_info("CHIRAGDBGWR", $sformatf("beat_offset %0d m_data 0x%0x",m_beat_offset, m_data), UVM_NONE);
            /************************************************************************ 
            // Following code was to support narrow transfers, but did not compile
            //foreach(data[i]) begin
            //    axi_xdata_t m_tmp_data1;
            //    axi_xdata_t m_tmp_data2;
            //    bit                                    m_data_size[];
            //    m_data_size = new [2**size * 8];
            //    for (int j = 0; j < WXDATA/8; j++) begin
            //        for (int k = 0; k < 8; k++) begin
            //            m_tmp_data1[k+8*j] = data[k+8*j] & strb[j];
            //            m_tmp_data2[k+8*j] = m_data[k+8*j] & ~strb[j];
            //        end
            //    end
            //    m_data_size = (2**size * 8)'(m_tmp_data1 >> m_offset);
            //    case (axi_axsize_enum_t'(size))
            //        AXI1B   : m_data[m_offset*8 +: 8*2**1] = m_tmp_data2[m_offset*8 +: 8*2**1] | m_data_size;
            //        AXI2B   : m_data[m_offset*8 +: 8*2**2] = m_tmp_data2[m_offset*8 +: 8*2**2] | m_data_size;
            //        AXI4B   : m_data[m_offset*8 +: 8*2**4] = m_tmp_data2[m_offset*8 +: 8*2**4] | m_data_size;
            //        AXI8B   : m_data[m_offset*8 +: 8*2**8] = m_tmp_data2[m_offset*8 +: 8*2**8] | m_data_size;
            //        AXI16B  : m_data[m_offset*8 +: 8*2**16] = m_tmp_data2[m_offset*8 +: 8*2**16] | m_data_size;
            //        AXI32B  : m_data[m_offset*8 +: 8*2**32] = m_tmp_data2[m_offset*8 +: 8*2**32] | m_data_size;
            //        AXI64B  : m_data[m_offset*8 +: 8*2**64] = m_tmp_data2[m_offset*8 +: 8*2**64] | m_data_size;
            //        AXI128B : m_data[m_offset*8 +: 8*2**128] = m_tmp_data2[m_offset*8 +: 8*2**128] | m_data_size;
            //    endcase
            //    m_offset += 2**size; 
            //end
            ************************************************************************/ 


            //Taking care of weird wrap case
            //if (burst == AXIWRAP) begin
            //    axi_xdata_t data_wrap[] = new []; 
            //    axi_xstrb_t strb_wrap[] = new []; 
            //    //uvm_report_info("CHIRAG ACE$MODEL write_data", $sformatf("lower_boundary 0x%0x upper_boundary 0x%0x aligned addr 0x%0x address 0x%0x first arg 0x%0x second arg 0x%0x start addr 0x%0x num_bytes 0x%0x dtsize 0x%0x", lower_boundary, upper_boundary, aligned_addr, addr, ((addr/(WXDATA/8)) * (WXDATA/8)), ((addr/(SYS_nSysCacheline)) * (SYS_nSysCacheline)), start_addr, num_bytes, dt_size), UVM_NONE);
            //    if ((dt_size < SYS_nSysCacheline) &&  
            //        (lower_boundary < ((addr/(WXDATA/8)) * (WXDATA/8))) 
            //    ) begin
            //        int j = 0;
            //        axi_xdata_t     m_tmp_data1;
            //        axi_xdata_t     m_tmp_data2;
            //        is_data_capture_done = 1;
            //        //uvm_report_info("CHIRAG ACE$MODEL write_data", $sformatf("START Address 0x%0x Data to copy from %0p cacheline data %0p", addr, m_ort[m_tmp_qA[0]].m_data, m_data), UVM_NONE);
            //        for (int i = 0; i < len + 1; i++) begin 
            //            data_wrap[beat_count_of_req] = data[i];
            //            strb_wrap[beat_count_of_req] = strb[i];
            //            if (start_addr >= upper_boundary && beat_count == 0) begin
            //                beat_count = len + 1 - i;
            //            end
            //            start_addr = start_addr + num_bytes;
            //            beat_count_of_req_tmp++;
            //            if (beat_count_of_req_tmp == len + 1) begin
            //                beat_count_of_req_tmp = 0;
            //            end
            //        end
            //        //uvm_report_info("CHIRAG ACE$MODEL write_data", $sformatf("Number of beats to copy over %0d", beat_count), UVM_NONE);
            //        for (int i = len + 1 - beat_count; i < len + 1; i++) begin
            //            data_wrap[i] = data[len + 1 - beat_count + j];
            //            j++;
            //            beat_count_of_req_tmp++;
            //        end
            //        //uvm_report_info("CHIRAG ACE$MODEL write_data", $sformatf("END Address 0x%0x Data to copy from %0p cacheline data %0p", addr, m_ort[m_tmp_qA[0]].m_data, m_data), UVM_NONE);
            //        for (int j = 0; j < WXDATA/8; j++) begin
            //            for (int k = 0; k < 8; k++) begin
            //                m_tmp_data1[k+8*j] = data_wrap[i][k+8*j] & strb[i][j];
            //                m_tmp_data2[k+8*j] = m_data[k+8*j + m_beat_offset * WXDATA] & ~strb[i][j];
            //            end
            //        end
            //        m_data[m_beat_offset * WXDATA +: WXDATA] = m_tmp_data1 | m_tmp_data2;
            //        //uvm_report_info("CHIRAGDBGWR", $sformatf("beat_offset %0d m_data 0x%0x data 0x%0x strb 0x%0x",m_beat_offset, m_data, data[i], strb[i]), UVM_NONE);
            //        m_beat_offset++;
            //        if (m_beat_offset == SYS_nSysCacheline*8/WXDATA) begin
            //            m_beat_offset = 0;
            //        end
            //    end
            //end
            //if (!is_data_capture_done) begin
            addr_offset = addr[SYS_wSysCacheline-1:0];
            align_addr_offset = ((addr_offset >> (size)) << (size)) * 8;
            axi_bus_offset = addr[WLOGXDATA-1 : 0];
            axi_bus_aligned_offset = ((axi_bus_offset >> (size)) << (size)) * 8;
            foreach(data[i]) begin
                axi_xdata_t     m_tmp_data1;
                axi_xdata_t     m_tmp_data2;
                bit [511:0]     m_tmp_data;
                bit [63:0]      m_tmp_strb;
                if(i==0) packet_num = 0;
                for (int j = 0; j<(WXDATA/8); j=j+1) begin
                    if((j >= (axi_bus_aligned_offset/8)) && (j <((2**size) + (axi_bus_aligned_offset/8)))) begin
                        for (int k = 0; k < 8; k++) begin
                            m_tmp_data1[k+(8*j)] = data[i][k+(8*j)] & strb[i][j];
                            m_tmp_data2[k+(8*j)] = m_data[k+(8*j) + (align_addr_offset-axi_bus_aligned_offset) + (packet_num*2**size*8)] & ~strb[i][j];
                        end
                        m_tmp_strb[j] = 1;
                    end else begin
                    end
                end

                //m_data[m_beat_offset * WXDATA +: WXDATA] = m_tmp_data1 | m_tmp_data2;
                m_tmp_data = m_tmp_data1 | m_tmp_data2;
                m_tmp_2       = (align_addr_offset-axi_bus_aligned_offset) + (packet_num*2**size*8);
                m_tmp_data    = m_tmp_data << m_tmp_2;
                m_tmp_strb    = m_tmp_strb << (m_tmp_2/8);

                for (int zero_bits=0; zero_bits<64; zero_bits=zero_bits+1) begin
                    for (int k = 0; k < 8; k++) begin
                        if(m_tmp_strb[zero_bits]==1) m_data[k+(8*zero_bits)] = m_data[k+(8*zero_bits)] & ~m_tmp_strb[zero_bits];
                    end
                end
                m_data1        = m_data | m_tmp_data;
                m_data         = m_data1;
                
                //uvm_report_info("CHIRAGDBGWR", $sformatf("m_data 0x%0x m_data1 0x%0x data 0x%0x strb 0x%0x m_tmp_data1 0x%0x m_tmp_data2 0x%0x m_tmp_data 0x%0x m_tmp_2 %0d axi_bus_aligned_offset %0d align_addr_offset %0d m_tmp_strb 0x%0x", m_data, m_data1, data[i], strb[i], m_tmp_data1,m_tmp_data2,m_tmp_data,m_tmp_2,axi_bus_aligned_offset,align_addr_offset,m_tmp_strb), UVM_NONE);
                axi_bus_aligned_offset = ((axi_bus_aligned_offset + (2**size*8))>=WXDATA) ? 0 :(axi_bus_aligned_offset + (2**size*8));
                packet_num = packet_num + 1;
                if (axi_axburst_enum_t'(burst) == AXIWRAP) begin
                    if((m_tmp_strb[63]==1) || (i==(data.size()-1))) begin // In case of cacheline change or wrap
                      m_tmp_2 = 0;
                      packet_num = 0;
                      m_memory[m_cache_aligned_addr] = m_data1;
                      align_addr_offset = 0;
                      axi_bus_aligned_offset = 0;
                    end
                end else if (axi_axburst_enum_t'(burst) == AXIINCR) begin
                    if((m_tmp_strb[63]==1) || (i==(data.size()-1))) begin // In case of cacheline change or wrap
                      m_tmp_2 = 0;
                      packet_num = 0;
                      m_memory[m_cache_aligned_addr] = m_data1;
                      m_cache_aligned_addr = m_cache_aligned_addr + SYS_nSysCacheline;
                      align_addr_offset = 0;
                      axi_bus_aligned_offset = 0;
                    end
                end
                //m_beat_offset++;
                //m_beat_offset_counter++;
                ////if (m_beat_offset == SYS_nSysCacheline*8/WXDATA) begin
                //// Below can only happen on WRAPs
                //if (m_beat_offset_counter == len + 1) begin
                //    m_beat_offset_counter = 0;
                //    m_beat_offset = m_offset >> WLOGXDATA;
                //    case (len)
                //        1: m_beat_offset[0] = 0; 
                //        3: m_beat_offset[1:0] = 0; 
                //        7: m_beat_offset[2:0] = 0; 
                //        15: m_beat_offset[3:0] = 0; 
                //    endcase
                //end
            end
            uvm_report_info("AXI MEM MODEL", $sformatf("write_data: address 0x%0x = 0x%0x", m_cache_aligned_addr, m_data), UVM_LOW);
        end
    endfunction : write_data


endclass : axi_memory_model
