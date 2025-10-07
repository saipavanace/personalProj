
class directed_test extends base_test;
    `uvm_component_utils(directed_test)
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        uvm_event ev_<%=i%> = ev_pool.get("ev_<%=i%>");
    <%}%>

    bit [31:0] data;
    axi_arid_t          id;
    axi_axaddr_t        addr;
    axi_axlen_t         len;
    axi_axsize_t        size;
    axi_axburst_t       burst;
    bit                 lock;
    bit [3:0]           cache;
    axi_axprot_t        prot;
    bit [1:0]           domain;
    ioaiu_csr_attach_seq_0     sysco_attach_seq;
    <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        io_aiu_default_reset_seq_<%=i%> default_seq_<%=i%>;
    <%}%>
    
    <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        ioaiu_csr_illegal_format_access_<%=i%> illegal_csr_access_<%=i%>;
        ioaiu_csr_uuedr_MemErrDetEn_seq_<%=i%> csr_uuedr_MemErrDetEn<%=i%>;
    <%}%>

    string reg_name_q[$];
    string reg_name;
    bit [`UVM_REG_ADDR_WIDTH-1 : 0] reg_addr_q[$];

	function new(string name = "directed_test", uvm_component parent=null);
    	super.new(name,parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        <%if(obj.INHOUSE_APB_VIP){%>
            csr_default_sequence();
        <%}%>
	endfunction : build_phase

	task run_phase (uvm_phase phase);
	    super.run_phase(phase);
        phase.raise_objection(this, "Start_test"); 

        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
	        uvm_config_db#(ioaiu_scoreboard)::set(uvm_root::get(), "*", "ioaiu_scb_<%=i%>", mp_env.m_env[<%=i%>].m_scb);
	    <%}%>
        
        if ($test$plusargs("single_rdnosnp")) begin
            single_rdnosnp();
        end else if ($test$plusargs("large_multiline_txn")) begin

        end
        <%if(obj.INHOUSE_APB_VIP){%>
	        start_deafult_sequence();
	    <%}%>
        if ($test$plusargs("dir_atomic_txns")) begin
            atomic_txns();
        end
        if ($test$plusargs("enable_livelock")) begin
            livelock_sequence();
        end
	    phase.drop_objection(this, "Finish_test");         	
	endtask:run_phase

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
	endfunction: report_phase

	function void fill_reg_name_and_addr_q();
        axi_axaddr_t reg_init_addr;
        if($test$plusargs("iill_csr_access_with_unaligned_address"))
		    reg_init_addr = ncoreConfigInfo::NRS_REGION_BASE + 'hff;
        else
            reg_init_addr = ncoreConfigInfo::NRS_REGION_BASE;

                //store register names & addr in q
        <% obj.DutInfo.csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
            reg_addr_q.push_back((<%=item.addressOffset%> + reg_init_addr));
            reg_name_q.push_back("<%=item.name%>");
        <% }); %>
	endfunction: fill_reg_name_and_addr_q

	function axi_axaddr_t get_addr_for_register(string name);
        foreach(reg_name_q[ind]) begin
            if(reg_name_q[ind] == name) begin
                `uvm_info(get_type_name(), $sformatf("DIR_TEST_DEBUG:  reg name:%s, addr:0x%0h", name, reg_addr_q[ind]),UVM_LOW)
                return(reg_addr_q[ind]);
            end
        end
	endfunction: get_addr_for_register

    task read_hit();
        assign_seqr_handles();
        addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0);
        for (int i=0; i< 2; i++) begin
            id=i;
            len=0;
            size=0;//0-3
            burst=1;
            if(i == 0)
            cache[2]= 1;
            cache[1]= 1;
            domain=0;
            issue_txn(.cmdtype(RDONCE), .addr(addr), .len(len), .size(size), .burst(burst), .id(id), .cache(cache), .domain(domain));
         end
    endtask: read_hit

	task single_rdnosnp();
        assign_seqr_handles();

        addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0);
        len=0;
        id=2;
        size=3;
        burst=1;
        prot[1]=$urandom_range(0,1);
        `uvm_info(get_type_name(), $sformatf("DIR_TEST_DEBUG:  cmd:%s, addr:0x%0h, len:0x%0h, size:0x%0h, burst:0x%0h, id:0x%0h", RDNOSNP, addr, len, size, burst, id),UVM_LOW)
        issue_txn(.cmdtype(RDNOSNP), .addr(addr), .len(len), .size(size), .burst(burst), .id(id), .prot(prot));
    endtask: single_rdnosnp

    task livelock_sequence();
        assign_seqr_handles();
        cache[1] = 1;
        // Fill OTT with reads and send a write
        fork
            begin
                for (int i=0; i<8; i++) begin
                    addr = m_addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0);
                    issue_txn(.cmdtype(RDNOSNP), .addr(addr), .len(0), .size(4), .burst(1), .id($urandom_range(1,1000)));
                end
            end
            begin
                #200ns;
                for (int i=0; i<6; i++) begin
                    addr = m_addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0);
                    issue_txn(.cmdtype(WRNOSNP), .addr(addr), .len(0), .size(4), .burst(1), .id($urandom_range(1,1000)), .cache(cache));
                end
            end
            begin
                // try sending dvm transaction to consume all OTT entries - Sai
            end
        join

        #1us;
        // Fill OTT with writes and send a read
        fork
            begin
                #200ns;
                for (int i=0; i<10; i++) begin
                    addr = m_addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0);
                    issue_txn(.cmdtype(RDNOSNP), .addr(addr), .len(0), .size(4), .burst(1), .id($urandom_range(1,1000)));
                end
            end
            begin
                for (int i=0; i<10; i++) begin
                    addr = m_addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0);
                    issue_txn(.cmdtype(WRNOSNP), .addr(addr), .len(0), .size(4), .burst(1), .id($urandom_range(1,1000)), .cache(cache));
                end
            end
            begin
                // try sending dvm transaction to consume all OTT entries - Sai
            end
        join

    endtask : livelock_sequence

	task issue_txn(ace_command_types_enum_t cmdtype, axi_axaddr_t addr, axi_axlen_t len, axi_axsize_t size, axi_axburst_t burst, axi_arid_t id=0, bit lock=0, bit[3:0] cache=0, axi_axprot_t prot=0, bit[1:0] domain=0/*, axi_axqos_t qos, axi_axregion_t region, axi_aruser_t user*/);
        bit wr=0;
        if (cmdtype inside{WRNOSNP, WRUNQ, WRLNUNQ, WRCLN, WRBK, EVCT, WREVCT, ATMSTR, ATMSWAP, ATMLD, ATMCOMPARE})
            wr=1;
        `uvm_info(get_type_name(), $sformatf("DIR_TEST_DEBUG: cmd:%s, addr:0x%0h, len:0x%0h, size:0x%0h, burst:0x%0h, id:0x%0h, prot:0x0%0h", cmdtype, addr, len, size, burst, id, prot),UVM_LOW)
        if(wr) begin
            axi_single_wr_seq m_seq;
            m_seq           = axi_single_wr_seq::type_id::create("m_wr_seq");
            m_seq.dis_post_randomize = 1;
            m_seq.m_cmdtype = cmdtype;
            m_seq.m_addr    = addr;    
            m_seq.m_id      = id;
            m_seq.m_axlen   = len;
            m_seq.m_size    = size;
            m_seq.m_burst   = burst;
            m_seq.m_prot    = prot;
            m_seq.m_cache   = axi_awcache_enum_t'(cache);
            m_seq.m_domain  = axi_axdomain_enum_t'(domain);
            m_seq.start(mp_env.m_ioaiu_vseqr[0]);
        end else begin 
            axi_single_rd_seq m_seq;
            m_seq           = axi_single_rd_seq::type_id::create("m_rd_seq");
            m_seq.dis_post_randomize = 1;
            m_seq.m_cmdtype = cmdtype;
            m_seq.m_addr    = addr;
            m_seq.mcache    =  axi_arcache_enum_t'(cache);
            m_seq.sel_bank  =  sel_bank; 
            m_seq.use_arid  = id;
            m_seq.m_axlen   = len;
            m_seq.m_size    = size;
            m_seq.m_burst   = burst;
            m_seq.m_prot    = prot;
            m_seq.start(mp_env.m_ioaiu_vseqr[0]);
        end
	endtask: issue_txn;

        //#Stimulus.IOAIU.IllegalCSRaccess.DECERR
	task csr_access_via_nativeintf();
        int   m_tmp_q[$];
        assign_seqr_handles();
        fill_reg_name_and_addr_q();
        m_tmp_q = {};
        if($test$plusargs("iill_csr_access_with_unaligned_address"))
            m_tmp_q = reg_addr_q.find_index with (item % 4 != 0);
        else
            m_tmp_q = reg_addr_q.find_index with (item % 8 == 0);

        for (int i=0; i< 20; i++) begin
            ace_command_types_enum_t cmd_type;
            string register_name;
            int index;
            int j;
            //pick some random register from the q
            
            index = $urandom_range(0,(m_tmp_q.size()-1));
            j = m_tmp_q[index];
            register_name = reg_name_q[j];

            addr = get_addr_for_register(register_name);
            <%if(obj.AiuInfo[obj.Id].aNcaiuIntvFunc===undefined || obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits===undefined || !obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length){
                // do nothing
            }else{%>
                <%for(var i=0; i<obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length; i++){%>
                    addr[<%=obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[i]%>] = 0;
                <%}%>
            <%}%>
            len = 0;
            id = i;
            if($test$plusargs("iill_csr_access_with_not_four_byte"))
            size = 3;
            else
            size = 2;
            burst = 1;
            prot[1] = i%2;
            cmd_type = ($urandom_range(0,1))? RDNOSNP : WRNOSNP;
            domain=3;
            issue_txn(.cmdtype(cmd_type), .addr(addr), .len(len), .size(size), .burst(burst), .id(id), .prot(prot), .domain(domain));
        end
	endtask: csr_access_via_nativeintf;

    <%if(obj.INHOUSE_APB_VIP){%>
	    function csr_default_sequence();
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                default_seq_<%=i%> = io_aiu_default_reset_seq_<%=i%>::type_id::create("default_seq_<%=i%>");
                default_seq_<%=i%>.coreId = <%=i%>;
            <%}%>
            sysco_attach_seq = ioaiu_csr_attach_seq_0::type_id::create("sysco_attach_seq");
                       //Set up TransOrderMode
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                default_seq_<%=i%>.dvm_resp_order = this.dvm_resp_order;
                default_seq_<%=i%>.tctrlr  = this.tctrlr;
            <%}%>
            <% if (obj.DutInfo.useCache) {%>
                //legacy set to 1 TODO randomize ?
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    if(!($value$plusargs("ccp_lookupen=%0d",default_seq_<%=i%>.ccp_lookupen))) begin
                        default_seq_<%=i%>.ccp_lookupen  = 1;
                    end
                <%}%>
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    if(!($value$plusargs("ccp_allocen=%0d",default_seq_<%=i%>.ccp_allocen))) begin
                            default_seq_<%=i%>.ccp_allocen   = 1;
                    end
                <%}%>
            <%}%>
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                default_seq_<%=i%>.topcr0  = this.topcr0;
                default_seq_<%=i%>.topcr1  = this.topcr1;
                default_seq_<%=i%>.tubr  = this.tubr;
                default_seq_<%=i%>.tubmr = this.tubmr;
            <%}%>
              
            <%for ( let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                illegal_csr_access_<%=i%>  = ioaiu_csr_illegal_format_access_<%=i%>::type_id::create("illegal_csr_access_<%=i%>");
                csr_uuedr_MemErrDetEn<%=i%>  = ioaiu_csr_uuedr_MemErrDetEn_seq_<%=i%>::type_id::create("csr_uuedr_MemErrDetEn<%=i%>");
            <%}%>
            
	    endfunction: csr_default_sequence
    <%}%>

       
    <%if(obj.INHOUSE_APB_VIP){%>
        task start_deafult_sequence();

            <%if(obj.INHOUSE_APB_VIP){%>

                sysco_attach_seq.model         = mp_env.m_env[0].m_regs;
                <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
                    sysco_attach_seq.scb_en[<%=j%>] = m_env_cfg[<%=j%>].has_scoreboard; 
                    sysco_attach_seq.ioaiu_scb[<%=j%>] 	= mp_env.m_env[<%=j%>].m_scb;
                <%}%>
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    default_seq_<%=i%>.model       = mp_env.m_env[0].m_regs;
                <%}%>
                <%for (let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        illegal_csr_access_<%=i%>.model       = mp_env.m_env[0].m_regs;
                    csr_uuedr_MemErrDetEn<%=i%>.model       = mp_env.m_env[0].m_regs;
                <%}%>
            
                `uvm_info("run_main", "default_seq started",UVM_NONE)
                fork
                    <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                        default_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                    <%}%>
                join
                `uvm_info("run_main", "default_seq finished",UVM_NONE)
                #100ns;
            <%}%>

            <%if(obj.INHOUSE_APB_VIP){%>
                <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
                    begin //attach seq
                        `uvm_info("run_main", "ioaiu_csr_attach_seq_started", UVM_NONE)
                        sysco_attach_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                        `uvm_info("run_main", "ioaiu_csr_attach_seq_finished", UVM_NONE)
                    end
                <%}%>
            <%}%>

            if($test$plusargs("address_error_test_data")) begin
                fork
                    <%for (let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        begin
                            csr_uuedr_MemErrDetEn<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                        end
                    <%}%>
                    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        begin
                            ev_<%=i%>.wait_ptrigger();
                            if($test$plusargs("read_hit")) begin
                                read_hit();
                            end
                        end
                    <%}%>
                join
            end
            if ($test$plusargs("csr_access_via_nativeintf")) begin
                fork
                    begin
                        if($test$plusargs("iill_csr_access_with_unaligned_address") || $test$plusargs("iill_csr_access_with_not_four_size") || $test$plusargs("illegalCSRAccess_no_EndPoint_order") || <%=obj.AiuInfo[obj.Id].fnCsrAccess %> == 0 ) begin
                            <%if(obj.INHOUSE_APB_VIP){%>
                                `uvm_info("run_main", "csr_seq started",UVM_NONE)
                                illegal_csr_access_0.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                                `uvm_info("run_main", "csr_seq finished",UVM_NONE)
                
                            <%}%>
                        end
                    end
                    begin
                        csr_access_via_nativeintf();
                    end  
                join       
            end
        endtask: start_deafult_sequence;
    <%}%>

    task atomic_txns();
        ace_command_types_enum_t atm_cmdtype;
        assign_seqr_handles();
        for (int i=0; i< 200; i++) begin
            std::randomize(atm_cmdtype) with { atm_cmdtype inside{ATMSTR, ATMSWAP, ATMLD, ATMCOMPARE};};
            addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0);
            id=i;
            len=0;
            size=(atm_cmdtype == ATMCOMPARE)? 1 : 0;//0-3
            burst=1;
            cache[3:2]=$urandom_range(1,3);
            cache[1]=1;
            cache[0]=$urandom_range(0,1);
            domain=0;
            //prot[1]=$urandom_range(0,1);
            issue_txn(.cmdtype(atm_cmdtype), .addr(addr), .len(len), .size(size), .burst(burst), .id(id), .cache(cache), .domain(domain));
        end
    endtask: atomic_txns

endclass: directed_test
