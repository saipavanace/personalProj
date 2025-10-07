////////////////////////////////////////////////////////////
//                                                        //
//Description: Helper classes for tests                   //
//                                                        //
//File:   helper_class.svh                                //
//Author: Abhinav Nippuleti                               //
//                                                        //
////////////////////////////////////////////////////////////

//Callback reporter message displayed on timeout
class timeout_catcher extends uvm_report_catcher;
    uvm_phase   phase;
    dmi_env env;
    bit         dmi_scb_en;
    uvm_objection   objection;
    uvm_object      object_list[$];

    `uvm_object_utils(timeout_catcher)

    function new(string name = "timeout_catcher");
        super.new(name);
    endfunction: new

    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id == "HBFAIL") begin
            objection = phase.get_objection();
            objection.get_objectors(object_list);
            objection.display_objections();
            `uvm_info("HBFAIL","Following object/objects have/has not dropped objection", UVM_NONE)
            foreach(object_list[i]) begin
                `uvm_info("HBFAIL", $sformatf("%0s", object_list[i].get_name()), UVM_NONE)
            end
            `uvm_info("TEST", "\n===========\nUVM FAILED!!!!\n===========", UVM_NONE);
            if (dmi_scb_en) begin
                uvm_report_info("DMI TB", $sformatf("Printing outstanding DMI scoreboard transactions"), UVM_NONE);
                env.m_sb.print_rtt_q_eos();
                env.m_sb.print_wtt_q_eos();
            end
            //obj.display_objections();
            uvm_report_fatal("HBFAIL", $psprintf("Heart Beat Failure Objection:"), UVM_NONE);
        end
        else if(get_severity() == UVM_ERROR) begin
            `uvm_info("TEST", "\n===========\nUVM FAILED!!!!\n===========", UVM_NONE);
            if (dmi_scb_en) begin
                uvm_report_info("DMI TB", $sformatf("---------------------------------------------------Pending DMI scb transactions-------------------------------------------------------------------------------------------------"), UVM_NONE);
                env.m_sb.print_rtt_q_eos();
                env.m_sb.print_wtt_q_eos();
                uvm_report_info("DMI TB", $sformatf("--------------------------------------------------DONE Pending DMI scb transactions---------------------------------------------------------------------------------------------"), UVM_NONE);
            end
            uvm_report_error(get_id(), get_message(), UVM_NONE);
        end
        return(THROW);
   endfunction: catch
endclass: timeout_catcher

