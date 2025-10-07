/*
 *brief report_catcher_demoter_base
 *UVM_ERROT to UVM_INFO Demoter, demote UVM_ERROR based on ID or MESSAGE of UVM_ERROR.
 */

`ifndef REPORT_CATCHER_DEMOTER_BASE
`define REPORT_CATCHER_DEMOTER_BASE

<% if (obj.useResiliency) { %>

class report_catcher_demoter_base extends uvm_report_catcher;
  string report_id = "report_catcher_demoter_base";

  int no_of_err_msg = 0;
  int no_of_err_id = 0;
  int unsigned no_of_err_msg_demoted[$];
  int unsigned no_of_err_id_demoted[$];
  string       exp_msg[$];
  string       exp_id[$];
  int unsigned string_offset = 0;
  //If we want that error should exactly the same as given, than make this bit 1
  bit          exact_match_msg[$];
  bit          exact_match_id[$];
  /*
   *if want to ignore error from all the other ID/Msg, apart
   *from the list provided in the array then set this
   */
  bit          not_of = 0;
  bit          demote_uvm_error = 1;
  bit          demote_uvm_warning = 0;
  bit          demote_uvm_fatal = 0;

  `uvm_object_utils_begin(report_catcher_demoter_base)
<% if((obj.testBench == 'dii')|| (obj.testBench == 'dmi') || (obj.testBench == 'dce') || (obj.testBench == 'dve')|| (obj.testBench == 'chi_aiu')|| (obj.testBench == 'io_aiu')) { %>
`ifndef VCS
    `uvm_field_array_string  (exp_msg             ,UVM_DEFAULT)
    `uvm_field_int           (no_of_err_msg       ,UVM_DEFAULT)
    `uvm_field_array_int     (exact_match_msg     ,UVM_DEFAULT)
    `uvm_field_array_string  (exp_id              ,UVM_DEFAULT)
    `uvm_field_int           (no_of_err_id        ,UVM_DEFAULT)
    `uvm_field_array_int     (exact_match_id      ,UVM_DEFAULT)
    `uvm_field_int           (not_of              ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_error    ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_warning  ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_fatal    ,UVM_DEFAULT)
    `uvm_field_array_int     (no_of_err_msg_demoted ,UVM_DEFAULT)
    `uvm_field_array_int     (no_of_err_id_demoted  ,UVM_DEFAULT)
`else // `ifndef VCS
    `uvm_field_queue_string  (exp_msg             ,UVM_DEFAULT)
    `uvm_field_int           (no_of_err_msg       ,UVM_DEFAULT)
    `uvm_field_queue_int     (exact_match_msg     ,UVM_DEFAULT)
    `uvm_field_queue_string  (exp_id              ,UVM_DEFAULT)
    `uvm_field_int           (no_of_err_id        ,UVM_DEFAULT)
    `uvm_field_queue_int     (exact_match_id      ,UVM_DEFAULT)
    `uvm_field_int           (not_of              ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_error    ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_warning  ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_fatal    ,UVM_DEFAULT)
    `uvm_field_queue_int     (no_of_err_msg_demoted ,UVM_DEFAULT)
    `uvm_field_queue_int     (no_of_err_id_demoted  ,UVM_DEFAULT)
`endif // `ifndef VCS ... `else ...
<% } else {%>
    `uvm_field_array_string  (exp_msg             ,UVM_DEFAULT)
    `uvm_field_int           (no_of_err_msg       ,UVM_DEFAULT)
    `uvm_field_array_int     (exact_match_msg     ,UVM_DEFAULT)
    `uvm_field_array_string  (exp_id              ,UVM_DEFAULT)
    `uvm_field_int           (no_of_err_id        ,UVM_DEFAULT)
    `uvm_field_array_int     (exact_match_id      ,UVM_DEFAULT)
    `uvm_field_int           (not_of              ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_error    ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_warning  ,UVM_DEFAULT)
    `uvm_field_int           (demote_uvm_fatal    ,UVM_DEFAULT)
    `uvm_field_array_int     (no_of_err_msg_demoted ,UVM_DEFAULT)
    `uvm_field_array_int     (no_of_err_id_demoted  ,UVM_DEFAULT)
<% } %>
  `uvm_object_utils_end
  /*
   *brief Constructor
   *Create a new transaction instance
   *parameter: name - Instance name of the transaction
   */
  function new(string name = "report_catcher_demoter_base");
    super.new(name);
  endfunction : new

  function void build();
    bit exact_match_msg_cnt;
    bit exact_match_id_cnt;
    no_of_err_msg = exp_msg.size();
    no_of_err_id  = exp_id.size();
    exact_match_msg_cnt = no_of_err_msg-exact_match_msg.size;
    exact_match_id_cnt  = no_of_err_id-exact_match_id.size;

    if(exact_match_msg_cnt>0) begin
      repeat(exact_match_msg_cnt) begin
        exact_match_msg.push_back('b0);
      end
    end
    if(exact_match_id_cnt>0) begin
      repeat(exact_match_id_cnt) begin
        exact_match_id.push_back('b0);
      end
    end
    `uvm_info(get_name() ,$sformatf("Build method: Demoter instance{%0s} is as below,\n %p", this.get_name(), this), UVM_DEBUG)
  endfunction : build

  /*
   *brief Function pattern_match_f
   *Function used to match two string given as input arguments.
   *If string matches it will return 1 else return 0.
   *It is used to compare a message or ID of an error with
   *expected error message or ID.
   */
  function bit pattern_match_f(
                                input string str1,
                                input string str2,
                                input bit ext_match,
                                input int unsigned err_num,
                                input bit msg_or_id
                               );

    int unsigned length_of_str1;
    int unsigned length_of_str2;
    bit match;

    length_of_str1 = str1.len();
    length_of_str2 = str2.len();
    `uvm_info(get_name() ,$sformatf("length of str1=%0d, length of str2=%0d", length_of_str1, length_of_str2), UVM_DEBUG)
    // Length comparision
    if(length_of_str2 == 0) begin
      if(msg_or_id == 1'b1) begin
        `uvm_info(get_name() ,$sformatf("Length of Expected Err message is ZERO, Doing nothing for err num %0d of err msg", err_num), UVM_DEBUG)
      end
      else begin
        `uvm_info(get_name() ,$sformatf("Length of Expected Err message is ZERO, Doing nothing for err num %0d of err id", err_num), UVM_DEBUG)
      end
      return 0;
    end
    else if(ext_match == 0) begin
      //lenght of expected error message can be same or less than actual error message
      if(length_of_str2 > length_of_str1) begin
        return 0;
      end
    end
    else begin
      //length of expected error message and actual message should same
      if(length_of_str2 != length_of_str1) begin
        return 0;
      end
    end

    //for(int i = string_offset; i < length_of_str2 ; i++)
    for(int i = string_offset; i < (string_offset + length_of_str1 - length_of_str2 + 1) ; i++) begin
      if(str1.substr(i,i + length_of_str2 - 1) == str2) begin
        match = 1'b1;
        return 1;
      end
    end

    if(match == 1'b0) begin
      return 0;
    end
  endfunction : pattern_match_f

  /*
   *brief Function catch
   *If severity is UVM_ERROR then change it to UVM_INFO.
   */
  function action_e catch();
    bit got_id_match;
    bit got_msg_match;
    bit [31:0] idx_id_match;
    bit [31:0] idx_msg_match;

    if(((get_severity() == UVM_ERROR) && demote_uvm_error) || ((get_severity() == UVM_FATAL) && demote_uvm_fatal) || ((get_severity() == UVM_WARNING) && demote_uvm_warning)) begin
      if(no_of_err_msg > 0) begin
        for(int i=0; i < no_of_err_msg; i++) begin
          if(not_of) begin
            got_msg_match = ~(pattern_match_f(.str1(get_message()), .str2(exp_msg[i]), .ext_match(exact_match_msg[i]), .err_num(i), .msg_or_id(1)));
            if(!got_msg_match) begin
              idx_msg_match = i;
              break;
            end
          end else begin
            got_msg_match = (pattern_match_f(.str1(get_message()), .str2(exp_msg[i]), .ext_match(exact_match_msg[i]), .err_num(i), .msg_or_id(1)));
            if(got_msg_match) begin
              idx_msg_match = i;
              break;
            end
          end
        end
        if(got_msg_match) begin
          set_severity(UVM_INFO);
          //set_action(UVM_NO_ACTION);
          set_verbosity(UVM_HIGH);
          no_of_err_msg_demoted[idx_msg_match] ++;
          `uvm_info(get_name()
            ,$sformatf("Demoted error for actual_id=%0s ,expected_id=%0s ,not_of=%0d ,ext_match=%0d, err_num=%0d, msg_or_id=%0d ,no_of_err_msg_demoted[%0d]=%0d"
              ,get_message() ,exp_msg[idx_msg_match] ,not_of ,exact_match_msg[idx_msg_match] ,idx_msg_match ,1 ,idx_msg_match ,no_of_err_msg_demoted[idx_msg_match])
            ,UVM_HIGH)
        end
      end

      if(no_of_err_id > 0) begin
        for(int i=0; i < no_of_err_id; i++) begin
          if(not_of) begin
            got_id_match = ~(pattern_match_f(.str1(get_id()), .str2(exp_id[i]), .ext_match(exact_match_id[i]), .err_num(i), .msg_or_id(0)));
            if(!got_id_match) begin // pattern matched which shouldn't be demoted
              idx_id_match = i;
              break;
            end
          end else begin
            got_id_match = (pattern_match_f(.str1(get_id()), .str2(exp_id[i]), .ext_match(exact_match_id[i]), .err_num(i), .msg_or_id(0)));
            if(got_id_match) begin // pattern matched which should be demoted
              idx_id_match = i;
              break;
            end
          end
        end
        if(got_id_match) begin
          set_severity(UVM_INFO);
          //set_action(UVM_NO_ACTION);
          set_verbosity(UVM_LOW);
          no_of_err_id_demoted[idx_id_match] ++;
          `uvm_info(get_name()
            ,$sformatf("Demoted error for actual_id=%0s ,expected_id=%0s ,not_of=%0d, ext_match=%0d, err_num=%0d, msg_or_id=%0d ,no_of_err_id_demoted[%0d]=%0d"
              ,get_id() ,exp_id[idx_id_match] ,not_of ,exact_match_id[idx_id_match] ,idx_id_match ,0 ,idx_id_match ,no_of_err_id_demoted[idx_id_match])
            ,UVM_HIGH)
        end
      end
    end
    return THROW;
  endfunction
endclass : report_catcher_demoter_base

<% } %>

`endif
