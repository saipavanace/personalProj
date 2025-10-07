class chi_subsys_random_coherency_test extends chi_subsys_base_test;

    //uvm_event kill_coherency_test   = ev_pool.get("kill_coherency_test");

    `uvm_component_utils(chi_subsys_random_coherency_test)

    chi_subsys_random_coherency_vseq m_random_coherency_vseq;

    //extern virtual task kill_test(uvm_phase phase);

    function new(string name = "chi_subsys_random_coherency_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_random_coherency_vseq = chi_subsys_random_coherency_vseq::type_id::create("m_random_coherency_vseq");
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
   	fork
	    begin
                <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
                    m_random_coherency_vseq.rn_xact_seqr<%=idx%> = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
                <%}%>
                `uvm_info(get_name(), "Starting chi_subsys_random_coherency_test", UVM_NONE)
                m_random_coherency_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                `uvm_info(get_name(), "Done chi_subsys_random_coherency_test", UVM_NONE)
            end

	    //begin
       	    //	kill_test(phase);   
	    //end
   	join_any
    endtask: run_phase

endclass: chi_subsys_random_coherency_test

//task chi_subsys_random_coherency_test::kill_test(uvm_phase phase);
//
//    uvm_object objectors_list[$];
//    uvm_objection objection;
//
//    if($test$plusargs("kill_coherency_test"))begin
//    	fork
//            begin
//            	kill_coherency_test.wait_ptrigger();
//           	`uvm_info("chi_subsys_random_coherency_test", $sformatf("kill_coherency_test event triggered"), UVM_LOW);
//           	// Fetching the objection from current phase
//           	objection = phase.get_objection();
//           	// Collecting all the objectors which currently have objections raised
//           	objection.get_objectors(objectors_list);
//           	// Dropping the objections forcefully
//           	         
//           	foreach(objectors_list[i]) begin
//           	    uvm_report_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_LOW);
//	   	    while(objection.get_objection_count(objectors_list[i]) != 0) begin
//           	        phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
//           	    end
//           	end
//           	`uvm_info("chi_subsys_random_coherency_test", $sformatf("Jumping to report_phase"), UVM_LOW);
//           	phase.jump(uvm_report_phase::get());
//            end
//    	join
//    end
//
//endtask: kill_test
