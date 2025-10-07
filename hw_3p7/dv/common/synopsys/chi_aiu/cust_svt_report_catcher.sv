class cust_svt_report_catcher extends uvm_report_catcher;
    function new(string name="cust_svt_report_catcher");
        super.new(name);
    endfunction

    /*Function to compare whether str2 is present in str1 or not. This function will return 1 if str2 is present in str1*/

    function pattern_match(string str1, str2);
        int l1, l2;

        l1 = str1.len();
        l2 = str2.len();
        pattern_match = 0 ;

        if(l2 > l1) begin
        return 0;
        end 

        for(int i = 0;i < l1-l2+1;i++) begin
            if(str1.substr(i,i+l2-1) == str2) begin
                return 1;
            end  
        end 
    endfunction

    virtual function action_e catch();
        if(get_severity() == UVM_ERROR) begin
            if((pattern_match(get_message(),"MN should issue only one Sync type DVM Operation at a time"))) begin
                `uvm_info(get_full_name(),$psprintf("Catch error message: %s. Demoted UVM_ERR0R to UVM_WARNING",get_message),UVM_HIGH)
                set_severity(UVM_WARNING);
            end 
        end
        if(get_severity() == UVM_ERROR) begin
            if((pattern_match(get_message(),"received when there is already an entry for same LPID in pending exclusive_read queue"))) begin
                `uvm_info(get_full_name(),$psprintf("Catch error message: %s. Demoted UVM_ERR0R to UVM_WARNING",get_message),UVM_HIGH)
                set_severity(UVM_WARNING);
            end
        end
        //if(get_severity() == UVM_ERROR) begin
        //    if((pattern_match(get_message(),"Source node for SNPDVMOP flit is not an MN"))) begin
        //        `uvm_info(get_full_name(),$psprintf("Catch error message: %s. Demoted UVM_ERROR to UVM_WARNING",get_message),UVM_HIGH)
        //        set_severity(UVM_WARNING);
        //    end 
        //end
        return THROW;
    endfunction 
endclass
