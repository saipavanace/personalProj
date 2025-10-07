
///////////////////////////////////////
//class: multi_chnl_data_container
//Details: 
//
///////////////////////////////////////

package multi_channel_data_cointainer_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef struct {
    int base_index;
    bit [63:0] offset_index;
    time halt_ch_st_time;
} halted_channels_t;

class multi_chnl_data_container #(type T = int) extends uvm_object;

    `uvm_object_param_utils(multi_chnl_data_container)

    ///////////////////////////////////////
    //Properties
    ///////////////////////////////////////
    //default channel
    T m_default_q[$];

    //initialization properties
    int  m_nbase_idxs, m_depth_th, m_halt_ch_wt, m_burst_pct;
    time t_halt_threshold;

    bit hurestic_set;

    //User controlled data containter.
    //User specifies where to store the data by providing base index
    //and offset index (both combined points to a channel). Certain channel's
    //are halt issuing responses either until timeout occurs or channel expected
    //depth is reached. 
    T m_hurestic_q[][bit[63:0]][$];
    
    ///////////////////////////////////////
    //Methods
    ///////////////////////////////////////
    //Initialization methods
    extern function new(string name = "multi_chnl_data_container");
    extern function void set_max_base_indexes(int indexes);
    extern function void set_depth_th4ch(int depth);
    extern function void set_wt2halt_channel(int wt);
    extern function void set_burst_traffic_pct(int pct);
    extern function void set_halt_time_threshold(time threshold);

    //Run time interface methods
    extern function void push(const ref T m_item, input int base_ptr = -1, int offset_ptr = -1);
    extern function bit peek(output T m_item, int base_ptr, int offset_ptr);
    extern task get_response(output T m_item, int base_ptr, int offset_ptr);
    extern function void delete_recent_response(input int base_ptr, int offset_ptr);

endclass: multi_chnl_data_container

//Constructor
function multi_chnl_data_container::new(string name = "multi_chnl_data_container");
    super.new(name);

    //default values
    m_depth_th       = 10;
    m_halt_ch_wt     = 0;
    m_burst_pct      = 90;
    t_halt_threshold = 10us;
endfunction: new

//Set number of Base indexes associated with set_max_base_indexes()
//In DCE it is equavalent to number of Tag Filters
function void multi_chnl_data_container::set_max_base_indexes(int indexes);
    this.m_nbase_idxs = indexes;
    if(hurestic_set) 
        `uvm_error(get_name(),
        "m_hurestic_q is already initialized. Only once constructed on test initialization")
    hurestic_set = 1'b1;
    m_hurestic_q = new[m_nbase_idxs];
endfunction: set_max_base_indexes

//Set max depth threshold per channel, Once the number of T packets reaches the
//dpeth threshold value for that channel then the channel will not halt responses
//anymore
function void multi_chnl_data_container::set_depth_th4ch(int depth);
    m_depth_th = depth;
endfunction: set_depth_th4ch

//Set burst traffic percentage 100 means no delays 0 means delay forever
//Legal values are 50 to 100, default value is 80
function void multi_chnl_data_container::set_burst_traffic_pct(int pct);
    if(pct < 50 || pct > 100) 
        `uvm_error(get_name(), "Legal values to indicate burst traffic pattern: 50 to 100")
    m_burst_pct = pct;
endfunction: set_burst_traffic_pct

//Set weight pct to halt channels. legal values are from 0 to 100.
//default value is 0
function void multi_chnl_data_container::set_wt2halt_channel(int wt);
    if(wt < 0 || wt > 100) 
        `uvm_error(get_name(), "Legal values to set weight on halting a channel is 0 to 100")
    m_halt_ch_wt = wt;
endfunction: set_wt2halt_channel

//Set Halt time threshold, default is 10us.
function void multi_chnl_data_container::set_halt_time_threshold(time threshold);
    t_halt_threshold = threshold;
endfunction: set_halt_time_threshold

//
//1. Push the item forwarded into the queue
//2. If base_ptr is not specified then push the packet to default queue
//
function void multi_chnl_data_container::push(const ref T m_item, input int base_ptr = -1,
    int offset_ptr = -1);
    if(base_ptr == -1) begin
        m_default_q.push_back(m_item);
    end
endfunction: push

//Peek into the container and return random entry
function bit multi_chnl_data_container::peek(output T m_item, int base_ptr, int offset_ptr);
    bit status;

    if(m_default_q.size()) begin
        int qidx;

        qidx = $urandom_range(0, m_default_q.size()-1);
        m_item = m_default_q[qidx];
        base_ptr = -1;
        offset_ptr = qidx;
        status = 1'b1;
    end

    return(status);
endfunction: peek

//Blocking call, Waits until packet is avaliable and returns the response.
task multi_chnl_data_container::get_response(output T m_item, int base_ptr, int offset_ptr);
    int qidx;

    wait(m_default_q.size() > 0);
    qidx = $urandom_range(0, m_default_q.size()-1);
    m_item = m_default_q[qidx];
    base_ptr = -1;
    offset_ptr = qidx;
endtask: get_response

function void multi_chnl_data_container::delete_recent_response(input int base_ptr, int offset_ptr);
    m_default_q.delete(offset_ptr);
endfunction: delete_recent_response

endpackage: multi_channel_data_cointainer_pkg
