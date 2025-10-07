
////////////////////////////////////////////////////////////////////////////////////////////
//class: dce_err_log_x_maint_test.svh
//Details
//    Test to verify logging of correctable/uncorrectable errors that happen in the system
//    Error injection is done through error maint rd/wr ops and then maint ops are scheduled
//    to hit the injected location and determinte the behavior.
//
//    Below table is for uncorrectable errors
//Filter     Operation  UErr H/M       Spec Behavior
//Enabled    Address    No   Miss      No modification
//                          Hit       Recall entry agents; invalidate entry
//                     Yes  N/A       No modification; log error; disable filter
//          Set/Way    No   Miss      No modification
//                          Hit       Recall entry agents; invalidate entry
//                     Yes  N/A       No modification; log error; disable filter
//Disabled   Address    No   N/A       Recall all agents; no modification (*)
//                     Yes  N/A       Recall all agents; no modification; log error (*)
//           Set/Way    No   N/A        No modification (*)
//                     Yes  N/A        No modification; log error (*)
//
//Notes:
//-	A Miss for a set/way operation means the entry is invalid; a 'Hit'
//        for a set/way operation means the entry is valid
//-	No modification means the state of the array is not changed
//////////////////////////////////////////////////////////////////////////////////////////

class dce_err_log_x_maint_test extends dce_csr_maint_test_base;
    
     dce_seq test_seq;
     dce_csr_maint_random_obj m_maint_op;

     //Error injected on
     int err_inj_sf;
     int err_inj_sf_entry;
     int err_inj_sf_way;
     <%=obj.BlockId + '_con'%>::cacheAddress_t err_inj_cacheline;

     //correctable error injected on secded memories
     int secded_sf_q[$];
     int tag_sf_q[$];

     `uvm_component_utils(dce_err_log_x_maint_test)

     extern function new(string name = "dce_err_log_x_maint_test", uvm_component parent = null);
     extern function void build_phase(uvm_phase phase);
     extern virtual task run_phase(uvm_phase phase);

endclass: dce_err_log_x_maint_test

function dce_err_log_x_maint_test::new(string name = "dce_err_log_x_maint_test");
    super.new(name, parent);
endfunction: new

function void dce_err_log_x_maint_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
<%

      
obj.SnoopFilterInfo.forEach(function(bundle, indx, array) {
    if(bundle.fnFilterType === "TAGFILTER") { %>
        tag_sf_q.push_back(<%=indx%>); 

<%          if(bundle.StorageInfo.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED") { %>
  
            secded_sf.push_back(<%=indx%>);
<%          }
    }
});
%>
    m_maint_op = new();
    if(secded_sf.size()) begin
        m_maint_op.set_weights(0,50,50,0,50,50);
    end else begin
        m_maint_op.set_weights(0,50,50,0,0,100);
    end

endfunction: build_phase

task run_phase(uvm_phase phase);
    int max_iter;
    bit test_done;
    string s;
    int count;

    max_iter = $urandom_range(2, 5);
    `uvm_info("dce_test", $psprintf("max number of iterations this test runs:%0d", max_iter), UVM_MEDIUM)
   
    fork
        begin: main_loop
            for(int idx = 0; idx < max_iter; idx++) begin
                `uvm_info("dce_test", $psprintf("Start of test loop count: %0d", idx), UVM_MEDIUM)
                generate_directed_traffic();

                `uvm_info("dce_test", $psprintf("All coherent ops are done: %0d", idx), UVM_MEDIUM)
                m_maint_op.randomize();
                //inject error on snoop filter
                err_inj_sf = $urandom_range(0, (tag_sf_q.size()-1));

                if(err_type == UNCOR_ERR) begin
                    $sformat(s, "uncor error is injected on sf:%0d", err_inj_sf);
                    `uvm_info("dce_test", s, UVM_MEDIUM)
                    count = 0;

                    while(count < 2) begin
                        //inject uncorrectable error
                        inject_uncor_error();
                        
                        if(maint_xact_type == 1) begin
                             $sformat(s, "uncor error is injected on sf:%0d and maint by addr op is performed", err_inj_sf);
                             perfrom_maint_addr_on_inj_uncor_err();
                            `uvm_info("dce_test", s, UVM_MEDIUM)
                        else begin
                             $sformat(s, "uncor error is injected on sf:%0d and maint by set/way op is performed", err_inj_sf);
                             perfrom_maint_set_index_on_inj_uncor_err();
                            `uvm_info("dce_test", s, UVM_MEDIUM)
                        end

                        //Poll Uncor error csr logs and then check if values are correctly logged
                        //If it is the second time then expect overflow bit is set.
                        poll_uncor_csr_and_cmp(count);

                        //Re-read loc where uncor is injected and make sure location is not modified
                        do_maint_read_on_uncor_loc_and_cmp();
                    end
                end else begin
                    $sformat(s, "cor error is injected on sf:%0d", err_inj_sf);
                    `uvm_info("dce_test", s, UVM_MEDIUM)

                    //inject correctable error
                    inject_cor_error(err_inj_sf);

                    if(maint_xact_type == 1) begin
                         $sformat(s, "cor error is injected on sf:%0d and maint by addr op is performed", err_inj_sf);
                         perfrom_maint_addr_on_inj_cor_err();
                        `uvm_info("dce_test", s, UVM_MEDIUM)
                    else begin
                         $sformat(s, "cor error is injected on sf:%0d and maint by set/way op is performed", err_inj_sf);
                         perfrom_maint_set_index_on_inj_cor_err();
                        `uvm_info("dce_test", s, UVM_MEDIUM)
                    end
                end
            end
            test_done = 1'b0;
        end: main_loop

        begin: obj_trc
            while(!test_done) begin
                maint_objectiions();
            end
        end: obj_trc
    join

endtask: run_phase
