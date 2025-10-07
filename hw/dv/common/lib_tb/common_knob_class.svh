////////////////////////////////////////////////////////////////////////////////
//
// Common Knobs class 
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
<% if(obj.testBench=="emu") { %>
`include "uvm_macros.svh"
<% } %>

typedef class common_knob_list;

typedef struct {
    int m_min_range;
    int m_max_range; 
} t_minmax_range;

typedef enum {CLP_EXACT, CLP_VALUE_PLUSARGS_ALL, CLP_REGEXP, RANDOMIZED, EXTERNALLY_OVERWRITTEN} t_knob_value_assignee; 

// constant
const int            m_weights_const[1]           = {100};
const t_minmax_range m_minmax_const_0[1]          = '{'{m_min_range:0,m_max_range:0}};
// Bathtub curve
const int            m_weights_for_weight_knobs[3] = {15, 70, 15};
const t_minmax_range m_minmax_for_weight_knobs[3]  = '{'{m_min_range:0,m_max_range:5}, '{m_min_range:5,m_max_range:100}, '{m_min_range:85,m_max_range:100}};
// Uniform distribution
const int            m_weights_for_percentage[1]   = {100};
const t_minmax_range m_minmax_for_percentage[1]    = '{'{m_min_range:1,m_max_range:100}};

// TODO: Allow for an set of knob values and equal weights of each knob value
// Can do this by adding another new with a different argument list
// TODO: Move to dv_lib area
class common_knob_class #(type T = int);

    localparam RANDOM_MAX = 1000000;

    local  T                           m_knob_value;
    local  string                      m_knob_name;
    local  string                      m_knob_uvm_hierarchy;
    local  int                         m_knob_parent_inst;
    local  string                      m_knob_full_name;
    local  int                         m_weights[];
    local  t_minmax_range              m_minmax[];
    local  t_knob_value_assignee       m_knob_value_assignee;
    static local common_knob_list      m_common_knob_list;
    static local uvm_cmdline_processor clp;
    local bit                          m_coverage_sampled; // Coverage will be sampled on the first get_value call
    local bit                          m_knob_type_is_string;
    local bit                          m_knob_type_is_int;

   <% if(obj.testBench == 'dii') { %>
   `ifdef CDNS
    function get_typename(input int T, output string cdns_type_name);
    cdns_type_name = $typename(T);
    endfunction : get_typename 
   `endif // `ifdef CDNS
   <% } %>
    function new (string m_knob_name, uvm_object parent, int m_weights[], t_minmax_range m_minmax[]);
        string arg_value;
        string arg_matches[$];
        int    arg_temp_value;
        <% if(obj.testBench == 'dii') { %>
        `ifdef CDNS
        T knob_type;
        string knob_type_cdns; 
        get_typename(knob_type,knob_type_cdns);
        `endif // `ifdef CDNS
        <% } %>
        m_coverage_sampled        = 0;
        m_knob_type_is_int        = 0;
        m_knob_type_is_string     = 0;
        this.m_knob_name          = m_knob_name;
        this.m_knob_uvm_hierarchy = parent.get_full_name();
        this.m_knob_parent_inst   = parent.get_inst_id();
        this.m_weights            = m_weights;
        this.m_minmax             = m_minmax;
        this.m_knob_full_name     = $sformatf("%s_%s_%d", m_knob_uvm_hierarchy, m_knob_name, m_knob_parent_inst);
        <% if(obj.testBench == 'dii') { %>
        `ifndef CDNS
        if (type(T) == type(string)) begin
            m_knob_type_is_string = 1;
        end else if (type(T) == type(int)) begin
            m_knob_type_is_int = 1;
        end else begin
            `uvm_error("Common Knob Class", $sformatf("For knob %s, type is not supported (only int and string are supported right now)", m_knob_full_name))
        end
        `else // `ifndef CDNS
         if (knob_type_cdns == "string") begin
            m_knob_type_is_string = 1;
         end else if (knob_type_cdns == "int") begin
            m_knob_type_is_int = 1;
        end else begin
            `uvm_error("Common Knob Class", $sformatf("For knob %s, type is not supported (only int and string are supported right now)", m_knob_full_name))
        end
        `endif // `ifndef CDNS
        <% } else {%>
        if (type(T) == type(string)) begin
            m_knob_type_is_string = 1;
        end else if (type(T) == type(int)) begin
            m_knob_type_is_int = 1;
        end else begin
            `uvm_error("Common Knob Class", $sformatf("For knob %s, type is not supported (only int and string are supported right now)", m_knob_full_name))
        end
        <% } %>

        if (m_weights.size() == 0) begin
            `uvm_error("Common Knob Class", $sformatf("For knob %s, number of weights is zero", m_knob_full_name))
        end
        if (this.m_weights.size() != this.m_minmax.size()) begin
            `uvm_error("Common Knob Class", $sformatf("For knob %s, number of weights does not match number of minmax ranges (m_weights %p m_minmax %p)", m_knob_full_name, m_weights, m_minmax))
        end
        if (clp == null) begin
            clp = uvm_cmdline_processor::get_inst();
        end
        if (m_common_knob_list == null) begin
            m_common_knob_list = common_knob_list::get_instance();
        end
      <% if(obj.testBench == 'dii') { %>
      `ifdef CDNS
       if(m_knob_name  != "k_32b_cmdset") begin
      `endif // `ifdef CDNS
       <% } %>
        if (m_common_knob_list.m_list_of_knobs.exists(m_knob_full_name)) begin
            m_common_knob_list.print();
            $stacktrace;
            `uvm_error("Common Knob Class", $sformatf("Duplicate knob being defined %s", m_knob_full_name))
        end
        <% if(obj.testBench == 'dii') { %>
       `ifdef CDNS
        end
       `endif // `ifdef CDNS
        <% } %>
        m_common_knob_list.m_list_of_knobs[m_knob_full_name] = this;
        // Below I need to add CLP and randcase statements
        if (clp.get_arg_value($sformatf("+%s=", m_knob_full_name), arg_value)) begin
            m_knob_value          = give_knob_value(arg_value);
            m_knob_value_assignee = CLP_EXACT;
            return;
        end 
        arg_temp_value = clp.get_arg_matches($sformatf("+%s=", m_knob_name), arg_matches); 
        if (arg_temp_value > 1) begin
            m_common_knob_list.print();
            `uvm_error("Common Knob Class", $sformatf("%s knob has multiple command line matches. They are %p", m_knob_full_name, arg_matches))
        end else if (arg_temp_value == 1) begin
            // Matching against first value found
            // TODO: Check what happens when "+knob_name" only is passed - not "+knob_name=knob_value"
            m_knob_value    = give_knob_value(clp_get_arg_value(arg_matches[0]));
            `uvm_info("Common Knob Class Debug", $sformatf("arg_matches %s knob value %d", arg_matches[0], m_knob_value), UVM_NONE)
            m_knob_value_assignee = CLP_VALUE_PLUSARGS_ALL;
            return;
        end

        // +k_burst_pct=100
        // +test_top_unit_env5_my_agent0_k_burst_pct=0
        // +env5.agent0.k_burst_pct=0




        // Ex: +aiu0.smi1.k_burst_pct=100
        arg_temp_value = clp.get_arg_matches($sformatf("/%s=/", m_knob_name), arg_matches); 
        if (arg_temp_value > 1) begin
            m_common_knob_list.print();
            `uvm_error("Common Knob Class", $sformatf("%s knob has multiple command line matches. They are %p", m_knob_full_name, arg_matches))
        end else if (arg_temp_value == 1) begin
            // Breaking down string format
            string values_array[$];
            string temp;
            int values_array_size;
            uvm_pkg::uvm_split_string(arg_matches[0], ".", values_array);
            // Remove the + at the head of the plusarg
            temp = values_array[0].substr(1, values_array[0].len()-1);
            values_array[0] = temp;
            //`uvm_info("CG DEBUG", $sformatf("Reached here %p", values_array), UVM_NONE)
            // Currently this file supports a.b.knob_name or a.knob_name and errors out with anything else
            values_array_size = values_array.size();
            unique if (values_array_size == 2) begin
                if (uvm_pkg::uvm_is_match($sformatf("*%s*", values_array[0]), m_knob_full_name)) begin
                    m_knob_value          = give_knob_value(clp_get_arg_value(arg_matches[0]));
                    m_knob_value_assignee = CLP_REGEXP;
                    return;
                end
            end else if (values_array_size == 3) begin
                if (uvm_pkg::uvm_is_match($sformatf("*%s*", values_array[0]), m_knob_full_name) &&
                    uvm_pkg::uvm_is_match($sformatf("*%s*", values_array[1]), m_knob_full_name)
                ) begin
                    m_knob_value          = give_knob_value(clp_get_arg_value(arg_matches[0]));
                    m_knob_value_assignee = CLP_REGEXP;
                    return;
                end
            end else begin
                m_common_knob_list.print();
                `uvm_error("Common Knob Class", $sformatf("For knob %s, there is a clp match found whose format is not x.knob_name or x.y.knob_name. It is %p which is unsupported", m_knob_full_name, arg_matches[0]))
            end
        end
        if (m_knob_type_is_string) begin
            m_common_knob_list.print();
            `uvm_error("Common Knob Class", $sformatf("%s is a string type but no matching knob was passed on command line. Randomization not supported for string types", m_knob_full_name))
        end else begin
            int m_weights_sum  = m_weights.sum();
            int m_random_value = $urandom_range(0,RANDOM_MAX);
            shortreal m_lower_bndry  = 0;
            shortreal m_upper_bndry  = 0;
            foreach (m_weights[i]) begin
                m_upper_bndry = m_lower_bndry + (RANDOM_MAX/m_weights_sum) * m_weights[i];
                //`uvm_info("CG DEBUG", $sformatf("random_value %d upper_bndry %f lower_bndry %f i %d weight[i] %d weight_sum %d", m_random_value, m_upper_bndry, m_lower_bndry, i, m_weights[i], m_weights_sum), UVM_NONE)
                if (m_random_value  < m_upper_bndry) begin
                    m_knob_value = $urandom_range(m_minmax[i].m_min_range, m_minmax[i].m_max_range);
                    break;
                end else begin
                    if(i==m_weights.size()-1) begin // CONC-11801 - Condition(m_random_value  < m_upper_bndry) does not hit & setting m_knob_value==0 which is causing unnecessary failure
                        m_knob_value = $urandom_range(m_minmax[i].m_min_range, m_minmax[i].m_max_range);
                    end
                end
                m_lower_bndry = m_upper_bndry;
            end
            m_knob_value_assignee = RANDOMIZED; 
        end
    endfunction : new 

    local function T give_knob_value(string m_clp_knob_value);
       <% if(obj.testBench == 'dii') { %>
       `ifdef CDNS
        T knob_type_1;
        string knob_type_cdns_1; 
        get_typename(knob_type_1,knob_type_cdns_1);
       `endif // `ifdef CDNS
        <% } %>
        <% if(obj.testBench == 'dii') { %>
        `ifndef CDNS
        unique if (type(T)==type(int)) begin
             return(m_clp_knob_value.atoi());
        end else if (type(T)==type(string)) begin
            $cast(give_knob_value, m_clp_knob_value);
        end
        `else // `ifndef CDNS
        unique if (knob_type_cdns_1=="int") 
      begin
           return(m_clp_knob_value.atoi());
        end else if (knob_type_cdns_1=="string") begin
            $cast(give_knob_value, m_clp_knob_value);
        end
        `endif // `ifndef CDNS
        <% } else {%>
        unique if (type(T)==type(int)) begin
             return(m_clp_knob_value.atoi());
        end else if (type(T)==type(string)) begin
            $cast(give_knob_value, m_clp_knob_value);
        end
        <% } %>
    endfunction : give_knob_value

    function string clp_get_arg_value(string arg_name);
        string value;
        string values_array[$];
        uvm_pkg::uvm_split_string(arg_name, "=", values_array);
        values_array[0] = {values_array[0], "="};
        clp.get_arg_value(values_array[0], value);
        `uvm_info("Common Knob Class Debug", $sformatf("clp_get_arg_value: arg_name %s value %s", arg_name, value), UVM_NONE)
        clp_get_arg_value = value;
    endfunction : clp_get_arg_value

    function T get_value();
        //FIXME: if you have a problem with obj.testBench, use obj.env_name instead - Need to check why this descrepancy is
        <% if(obj.env_name == 'dce' || obj.testBench == 'dmi' || obj.env_name == 'chi_aiu_snps' || obj.env_name == 'chi_aiu' || obj.env_name == 'cust_tb' || obj.testBench == 'fsys') { %>
        `ifndef VCS
        if (!m_coverage_sampled) begin
            m_coverage_sampled = 1;
            // TODO: Sample coverage property
        end
        `else // `ifndef VCS
       // if (!m_coverage_sampled) begin
       //     m_coverage_sampled = 1;
       //     // TODO: Sample coverage property
       // end
        `endif // `ifndef VCS ... `else ... 
        <% } else {%>
        if (!m_coverage_sampled) begin
            m_coverage_sampled = 1;
            // TODO: Sample coverage property
        end
        <% } %>
        return m_knob_value;
    endfunction : get_value

    function void set_value (T m_knob_value);
        this.m_knob_value     = m_knob_value;
        m_knob_value_assignee = EXTERNALLY_OVERWRITTEN;
    endfunction : set_value

    function string value_print_type();
        if (m_knob_type_is_int) begin
            return "Value: %0d";
        end
        return "Value: %p";
    endfunction : value_print_type

    function string convert2string();
        string toPrint = {"Knob: %s ", value_print_type(), " Value programmed from: %p"};
        return ($sformatf(toPrint, m_knob_full_name, m_knob_value, m_knob_value_assignee));
    endfunction : convert2string

endclass : common_knob_class
