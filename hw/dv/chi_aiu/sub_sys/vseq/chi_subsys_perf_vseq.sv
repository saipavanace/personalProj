class chi_subsys_perf_vseq extends chi_subsys_random_vseq;
    `uvm_object_utils(chi_subsys_perf_vseq)
    
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
    int txn_idx<%=idx%>;
    chi_subsys_perf_seq m_perf_cache_seq<%=idx%>;
    chi_subsys_perf_seq m_perf_seq<%=idx%>;
    <%}%>

    uvm_event_pool ev_pool_chisubsys = uvm_event_pool::get_global_pool();
    <%for(var pidx = 0; pidx < obj.nCHIs; pidx++) { %>
    uvm_event ev_wait_completion_of_seq_aiu<%=pidx%> = ev_pool_chisubsys.get("ev_wait_completion_of_seq_aiu<%=pidx%>");
    <% } %>

    function new(string name = "chi_subsys_perf_vseq");
        super.new(name);
        <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        m_perf_cache_seq<%=idx%> = chi_subsys_perf_seq::type_id::create("m_random_seq_cache_pre_filled<%=idx%>");
        m_perf_seq<%=idx%>       = chi_subsys_perf_seq::type_id::create("m_random_seq<%=idx%>");
        <%}%>

    endfunction: new

    virtual task body();

        if(init_all_cache > 0) begin
            `uvm_info("VSEQ", "Starting chi_subsys_perf_vseq to init DMI caches", UVM_NONE)

            fork
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                begin
                    if(1) begin //Each CHI init DMI cache by itself 
                    //if(init_from_chiaiu_idx == <%=idx%>) begin
                        txn_idx<%=idx%> = 0;
                        m_perf_cache_seq<%=idx%>.aiu_id         = <%=idx%>;
                        m_perf_cache_seq<%=idx%>.total_txn      = chi_num_trans;
                        m_perf_cache_seq<%=idx%>.qos            = qos[<%=idx%>];
                        m_perf_cache_seq<%=idx%>.init_all_cache = init_all_cache;

                        //for(int i =0;i<init_all_cache;i++) begin
                        //    if(txn_idx<%=idx%> == (init_all_cache - 1) ) begin
                        for(int i =0;i<chi_num_trans;i++) begin
                            if(txn_idx<%=idx%> == (chi_num_trans - 1) ) begin
                                m_perf_cache_seq<%=idx%>.blocking_mode = 1;
                            end
                            m_perf_cache_seq<%=idx%>.txn_idx  = txn_idx<%=idx%>;
                            if($test$plusargs("coherent_test")) begin //Skip init from CHI to Coherent IOAIU due to snoop possibility
                                <% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) {
                                if(obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE" || obj.AiuInfo[pidx].fnNativeInterface == "ACE" || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && obj.AiuInfo[pidx].useCache)) { %>
                                if((txn_idx<%=idx%> > ((<%=pidx%>*chi_num_trans)-1)) && (txn_idx<%=idx%> < ((<%=pidx%>*chi_num_trans)+chi_num_trans))) begin
                                    txn_idx<%=idx%>++; continue;
                                end <% }} %>
                            end
                            m_perf_cache_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                            txn_idx<%=idx%>++;
                        end
                    end
                end
                m_perf_cache_seq<%=idx%>.blocking_mode = 0;
                <%}%>
            join

            `uvm_info("VSEQ", "Finished chi_subsys_perf_vseq to init DMI caches", UVM_NONE)

        end else begin

            `uvm_info("VSEQ", "Starting chi_subsys_perf_vseq", UVM_NONE)

            fork
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    begin
                        if(chiaiu_en[<%=idx%>]) begin
                            <%if( idx > 0 ) { %>
                            if($test$plusargs("sequential") && chiaiu_en[<%=idx-1%>]) begin
                                ev_wait_completion_of_seq_aiu<%=idx-1%>.wait_ptrigger();
                            end
                            <%}%>
                            txn_idx<%=idx%> = 0;
                            m_perf_seq<%=idx%>.init_all_cache   = 0;
                            m_perf_seq<%=idx%>.aiu_id               = <%=idx%>;
                            m_perf_seq<%=idx%>.total_txn            = chi_num_trans;
                            m_perf_seq<%=idx%>.qos                  = qos[<%=idx%>];

                            repeat(chi_num_trans) begin
                                if($test$plusargs("sequential") && txn_idx<%=idx%> == chi_num_trans-1 ) begin
                                    m_perf_seq<%=idx%>.blocking_mode = 1;
                                end else begin
                                    m_perf_seq<%=idx%>.blocking_mode = 0;
                                end
                                m_perf_seq<%=idx%>.txn_idx  = txn_idx<%=idx%>;
                                m_perf_seq<%=idx%>.start(rn_xact_seqr<%=idx%>);
                                txn_idx<%=idx%>++;
                            end
                            m_perf_seq<%=idx%>.blocking_mode = 0;
                            ev_wait_completion_of_seq_aiu<%=idx%>.trigger();
                        end else begin
                            <%if( idx > 0 ) { %>
                            if($test$plusargs("sequential")) begin
                                ev_wait_completion_of_seq_aiu<%=idx-1%>.wait_ptrigger();
                            end
                            <%}%>
                            ev_wait_completion_of_seq_aiu<%=idx%>.trigger();
                        end
                    end
                <%}%>
            join

            `uvm_info("VSEQ", "Finished chi_subsys_perf_vseq", UVM_NONE)

        end
    endtask: body

endclass: chi_subsys_perf_vseq

