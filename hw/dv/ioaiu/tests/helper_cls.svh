////////////////////////////////////////////////////////////
//                                                        //
//Description: Helper classes for tests                   //
//                                                        //
//File:   helper_cls.svh                                  //
//Author: Abhinav Nippuleti                               //
//                                                        //
////////////////////////////////////////////////////////////

//Callback reporter message displayed on timeout
class timeout_catcher extends uvm_report_catcher;
    uvm_phase   phase;
    ioaiu_env env[<%=obj.DutInfo.nNativeInterfacePorts%>];
    system_bfm_seq m_system_bfm_seq;
   
    `uvm_object_utils(timeout_catcher)

    function new(string name = "timeout_catcher");
        super.new(name);
    endfunction: new

    function action_e catch();
        string spkt;
        uvm_objection obj = phase.get_objection();
        uvm_object list[$];
        if(get_severity() == UVM_FATAL && get_id == "HBFAIL") begin
            `uvm_info("TEST", "\n===========\nUVM FAILED!!!!\n===========", UVM_NONE);
<%if(obj.NO_SCB === undefined) { %>
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            if (env[<%=i%>].m_cfg.has_scoreboard) begin
                uvm_report_info("AIU TB", $sformatf("Printing outstanding AIU scoreboard transactions"), UVM_NONE);
                env[<%=i%>].m_scb.check_queues();
            end
		<% } %>
				m_system_bfm_seq.check_queues();
                if (m_system_bfm_seq.end_of_test_checks()) begin
                    uvm_report_info("AIU TB", $sformatf("Printing outstanding AIU System BFM transactions above"), UVM_NONE);
                end
<% } %>
	   obj.get_objectors(list);
	   //uvm_report_info("DCDEBUG", $sformatf("objectors list:%0p", list), UVM_LOW);

       obj.display_objections();
	   //uvm_report_info("DCDEBUG", $sformatf("objection count scb:%0d ", obj.get_objection_count(env.m_scb)), UVM_LOW);
            uvm_report_fatal("HBFAIL", $psprintf("Heart Beat Failure Objection:"), UVM_NONE);
        end
        else if(get_severity() == UVM_ERROR) begin

            if((!uvm_re_match(uvm_glob_to_re("*Expecting positive integer but caller supplied 0, returning -1*"),uvm_glob_to_re(get_message()))) 
               ) begin
                `uvm_info(get_full_name(),$psprintf("Catch error message: %s. Demoted UVM_ERROR to UVM_WARNING",get_message),UVM_LOW)
                set_severity(UVM_WARNING);
            end else begin
            `uvm_info("TEST", "\n===========\nUVM FAILED!!!!\n===========", UVM_NONE);
<%if(obj.NO_SCB === undefined) { %>
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            if (env[<%=i%>].m_cfg.has_scoreboard) begin
                uvm_report_info("AIU TB", $sformatf("---------------Pending AIU scb transactions---------------"), UVM_NONE);
                env[<%=i%>].m_scb.check_queues();
		<%if(obj.DutInfo.useCache) { %>
                uvm_report_info("AIU TB", $sformatf("-------------------Current Cache State--------------------"), UVM_NONE);
                for(int i=0;i<env[<%=i%>].m_scb.m_ncbu_cache_q.size;i++) begin
		    env[<%=i%>].m_scb.m_ncbu_cache_q[i].print();		       
		end
		<% } %>
            end
                uvm_report_info("AIU TB", $sformatf("---------------DONE Pending AIU scb transactions---------------"), UVM_NONE);
		<% } %>
<% } %>
             uvm_report_error(get_id(), get_message(), UVM_NONE);
        end
        end
        return(THROW);
   endfunction: catch
endclass: timeout_catcher

