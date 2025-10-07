//////////////////////////////
//                                                        //
//Description: Helper classes for tests                   //
//                                                        //
//File:   helper_cls.svh                                  //
<% if (1 ==0 ) { %>
//Author: satya prakash                                   //
<% } %>
//                                                        //
//////////////////////////////

//Reporter class print end of test results
<% 
var chiaiu_idx = 0;
var ioaiu_idx = 0;
var initiatorAgents = obj.nAIUs + obj.nCHIs; 
var initiators   = obj.AiuInfo.length ;
var aiu_NumCores = [];
 for(var pidx = 0; pidx < initiators; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
   } else {
       aiu_NumCores[pidx]    = 1;
   }
 }
%>

//Callback reporter message displayed on timeout
class timeout_catcher extends uvm_report_catcher;

    uvm_phase phase;
    report_test_status m_reporter;
    `uvm_object_param_utils(timeout_catcher)

    function new(string name = "timeout_catcher");
        super.new(name);
    endfunction: new

    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id == "HBFAIL") begin
            uvm_objection obj = phase.get_objection();
            obj.display_objections();

            m_reporter.report_results(1);
            `uvm_error("HBFAIL", $psprintf("Heart Beat Failure Objection:"));
            m_reporter.print_status();
            `uvm_fatal("HBFAIL", $psprintf("Heart Beat Failure Objection:"));
        end
        else if(get_severity() == UVM_ERROR) begin
               if((!uvm_re_match(uvm_glob_to_re("*Expecting positive integer but caller supplied 0, returning -1*"),uvm_glob_to_re(get_message()))) 
                || (!uvm_re_match(uvm_glob_to_re("*SNP_DVM_MSG Part 2 received does not respect restrictions fied values*"),uvm_glob_to_re(get_message())))
                || (!uvm_re_match(uvm_glob_to_re("*received when there is already an entry for same LPID in pending exclusive_read queue*"),uvm_glob_to_re(get_message())))
                || (!uvm_re_match(uvm_glob_to_re("*Invalid xact_type*on Slave port*based on port_interleaving_index*and port_interleaving_group_id*"),uvm_glob_to_re(get_message())))
               ) begin
                `uvm_info(get_full_name(),$psprintf("Catch error message: %s. Demoted UVM_ERROR to UVM_WARNING",get_message),UVM_LOW)
                set_severity(UVM_WARNING);
            end else begin
                uvm_objection obj = phase.get_objection();
                obj.display_objections();
                m_reporter.report_results(1);

                uvm_report_error(get_id(), get_message(), UVM_NONE);
                m_reporter.print_status();
                `uvm_fatal("HBFAIL", $psprintf("Heart Beat Failure Objection:"));
            end
        end
        else if(get_severity() == UVM_FATAL) begin
                if((!uvm_re_match(uvm_glob_to_re("*Expecting positive integer but caller supplied 0, returning -1*"),uvm_glob_to_re(get_message()))) 
                || (!uvm_re_match(uvm_glob_to_re("*SNP_DVM_MSG Part 2 received does not respect restrictions fied values*"),uvm_glob_to_re(get_message())))
                 || (!uvm_re_match(uvm_glob_to_re("*Invalid xact_type*on Slave port*based on port_interleaving_index*and port_interleaving_group_id*"),uvm_glob_to_re(get_message())))
            ) begin
                `uvm_info(get_full_name(),$psprintf("Catch error message: %s. Demoted UVM_ERROR to UVM_WARNING",get_message),UVM_LOW)
                set_severity(UVM_WARNING);
            end else begin
                uvm_objection obj = phase.get_objection();
                obj.display_objections();

                m_reporter.report_results(1);
            end
        end
 
        return(THROW);
   endfunction: catch

endclass: timeout_catcher
////////////////////////////////////////////////
//#######
//   #      ####    ####   #        ####
//   #     #    #  #    #  #       #
//   #     #    #  #    #  #        ####
//   #     #    #  #    #  #            #
//   #     #    #  #    #  #       #    #
//   #      ####    ####   ######   ####
////////////////////////////////////////////////
//RAL function
typedef int unsigned  queue_of_reg[uvm_reg];
typedef int unsigned  queue_of_block[uvm_reg_block];
function automatic queue_of_reg get_q_reg_by_regexpname(uvm_reg_block blk,string regexpname);
   int i;
   uvm_reg regs[$];
   string reg_exp_name;
   string reg_name;
   queue_of_reg ret;

  reg_exp_name = uvm_glob_to_re(regexpname);
  blk.get_registers(regs);
  foreach (regs[i]) begin 
     // revert uvm_reg [int] => int [uvm_reg]
      reg_name = regs[i].get_name();
      if (!uvm_re_match(reg_exp_name,reg_name)) // !!! if match !!!
         ret[regs[i]]= i;
  end
  return ret;
endfunction: get_q_reg_by_regexpname

function automatic queue_of_block get_q_block_by_regexpname(uvm_reg_block blk,string regexpname);
   int i;
   string reg_exp_name;
   uvm_reg_block blocks[$];
   string blk_name;
   queue_of_block ret;

   reg_exp_name = uvm_glob_to_re(regexpname);
   //doens't work //nbr=blk.find_blocks(regexpname,blocks);
   blk.get_blocks(blocks);
   foreach (blocks[i]) begin
      // revert uvm_reg_block [int] => int [uvm_reg_block]
      blk_name = blocks[i].get_name();
      if (!uvm_re_match(reg_exp_name,blk_name)) // !!! if match !!!
          ret[blocks[i]]= i;
      end
   return ret;
endfunction: get_q_block_by_regexpname

function automatic void ral_fill_field(uvm_reg reg_, string field_name, ref uvm_reg_data_t data, input int field_data);
      // fill only the corresponding field bits a data which are input & ouput (ref)
      uvm_reg_field ral_field;
      uvm_reg_data_t mask;

      ral_field = reg_.get_field_by_name(field_name);
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; 
      data |= ((field_data) << ral_field.get_lsb_pos()) ;
endfunction:ral_fill_field


/////////////////////////////////////////
// Demote of REGMODEL warning
// to avoid for example:
//UVM_WARNING /engr/dev/tools/mentor/questa-2021.2_1/questasim/verilog_src/uvm-1.1d/src/reg/uvm_reg_field.svh(1707) ...
// ... @ 0.00 ns: reporter [RegModel] Individual BACKDOOR field access not available for ...
// ... field 'ral_sys_ncore.dce1.DCEUGPRAR0.HUT'. Accessing complete register instead.
//
// to add in env build_phase:
//  catcher_regmodel = new("catcher_regmodel");
//  uvm_report_cb::add(null, catcher_regmodel);
//
///////////////////////////////////////
class regmodel_warning_catcher extends uvm_report_catcher; 
 
  function new (string name = "");
    super.new(name);
  endfunction
 
  function action_e catch; 
    uvm_severity severity  = get_severity();
    string       id        = get_id();
    uvm_action   action    = get_action();
    string       message   = get_message();
    int          verbosity = get_verbosity();
 
    if (severity == UVM_WARNING 
       && id == "RegModel"
       && 
       (   !uvm_re_match(uvm_glob_to_re("*Individual BACKDOOR field access not available for field*"),message)
        || !uvm_re_match(uvm_glob_to_re("*Individual field access not available for field*"),message)
        || !uvm_re_match(uvm_glob_to_re("*Unable to locate field*"),message)
        || !uvm_re_match(uvm_glob_to_re("*Target bus does not support byte enabling*"),message)
        || !uvm_re_match(uvm_glob_to_re("*uvm_reg_field::write(): Value greater than field*"),message)
       )   //message match
       )begin
      set_action(UVM_NO_ACTION);   // remove this message  
    end
    return THROW;         
  endfunction
endclass
  /////////////////////////////////////////
// Demote of SNPS VIP uvm_info message when UVM_FULL
// to avoid EACH cycle for example:
// UVM_INFO /engr/eda/tools/synopsys/vip_amba_svt_V-2023.09/vip/svt/amba_svt/V-2023.09-T-20230914/chi_rn_link_svt/sverilog/src/vcs/svt_chi_rn_link_active_common.svp(356) 
// @ 13174.69 ns: uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].link [transmit_rn_link_credits] Exiting ...
// UVM_INFO /engr/eda/tools/synopsys/vip_amba_svt_V-2023.09/vip/svt/amba_svt/V-2023.09-T-20230914/chi_rn_link_svt/sverilog/src/vcs/svt_chi_rn_link_active_base_common.svp(1216)
// @ 13175.31 ns: uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].link [transmit_link_credits] RXSNP[0]: rxla_can_xmit_lcrds = 1. Will attempt to drive LCRDV

///////////////////////////////////////
class snps_vip_catcher extends uvm_report_catcher; 
 
  function new (string name = "");
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
  
  function action_e catch; 
    uvm_severity severity  = get_severity();
    string       id        = get_id();
    uvm_action   action    = get_action();
    string       message   = get_message();
    int          verbosity = get_verbosity();
 
    if (severity == UVM_INFO 
       && id == "transmit_rn_link_credits"
       && 
       (   !uvm_re_match(uvm_glob_to_re("*Entering ...*"),message)
        || !uvm_re_match(uvm_glob_to_re("*Exiting ...*"),message)
       )   //message match
       )begin
      set_action(UVM_NO_ACTION);   // remove this message  
    end 
    if (severity == UVM_INFO 
       && id == "transmit_link_credits"
       && 
       (   !uvm_re_match(uvm_glob_to_re("*rxla_can_xmit_lcrds = 1.*"),message)
       )   //message match
       )begin
      set_action(UVM_NO_ACTION);   // remove this message  
    end
   
    //CONC-16898 This data_integrity_checker can be demoted since vip assumes
    //interconnect does not have a snoop filter in this check.
    if (severity == UVM_ERROR) begin 
      if (pattern_match(message, "Description: Monitor Check that the response to a coherent transaction is not started before sufficient information from snooped masters are obtained")) begin 
        //`uvm_info(get_full_name(),$psprintf("Catch error message: %s. Demoted UVM_ERROR to UVM_WARNING", message),UVM_LOW)
        set_severity(UVM_WARNING); 
      end
    end

    return THROW;         
  endfunction
 
endclass
