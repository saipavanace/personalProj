// The entire notice above must be reproduced on all authorized copies.
//----------------------------------------------------------------------------------------------------------------
// File     : snoop_filter_seq_item.sv
// Author   : yramasamy
// Notes    : seq item to monitor the snoop filter
//----------------------------------------------------------------------------------------------------------------

`ifndef __SNOOP_FILTER_SEQ_ITEM_SV__
`define __SNOOP_FILTER_SEQ_ITEM_SV__

class snoop_filter_seq_item extends uvm_object;
    // members of the class
    //---------------------------------------------------------------------------------------------------------------
    int     m_set_index;
    logic   m_rd0_wr1;
    int     m_way;
    longint m_data;

    // registering class to factory
    //---------------------------------------------------------------------------------------------------------------
   `uvm_object_utils(snoop_filter_seq_item);

    // function: new
    //---------------------------------------------------------------------------------------------------------------
    function new(string name="sf_seq_item");
        super.new(name);
    endfunction

    // function: convert2string
    //---------------------------------------------------------------------------------------------------------------
    function string convert2string();
        string data = (m_rd0_wr1 == 0) ? "ReadNotSampled" : $psprintf("0x%08h", m_data);
        return($psprintf("[type: %6s] [way: %2d] [set_index: 0x%08h] [data: %s]", m_rd0_wr1 == 0 ? "READ" : "WRITE", m_way, m_set_index, data));
    endfunction: convert2string

    // function: compare_item
    //---------------------------------------------------------------------------------------------------------------
    function void compare_item(logic rw, int way, int set_index, string signature="snpSeqItemCompare");
        logic  mismatch = 0;
        string match_str;

        mismatch  = (rw   != m_rd0_wr1        ) || (set_index != m_set_index) || (way != m_way);
        match_str = (rw   != m_rd0_wr1        ) ? $psprintf("[rd0_wr1: (expt: %1d != %1d :obsv)]", rw, m_rd0_wr1) : $psprintf("[rd0_wr1: (expt: %1d == %1d :obsv)]", rw, m_rd0_wr1);
        match_str = (way  != m_way            ) ? $psprintf("%s [way: (expt: 0x%016h != 0x%016h :obsv)]", match_str, way, m_way) : $psprintf("%s [way: (expt: 0x%016h == 0x%016h :obsv)]", match_str, way, m_way);
        match_str = (set_index != m_set_index ) ? $psprintf("%s [set_index: (expt: 0x%016h != 0x%016h :obsv)]", match_str, set_index, m_set_index) : $psprintf("%s [set_index: (expt: 0x%016h == 0x%016h :obsv)]", match_str, set_index, m_set_index);

        if(mismatch == 1) begin
           `uvm_error(get_name(), $psprintf("[%-35s] %s", signature, match_str)); 
        end
        else begin
           `uvm_info(get_name(), $psprintf("[%-35s] %s", signature, match_str), UVM_MEDIUM);
        end
    endfunction: compare_item

    // function: compare_item
    //---------------------------------------------------------------------------------------------------------------
    function bit does_it_match(snoop_filter_seq_item rhs);
        logic  matched;
        matched = (m_rd0_wr1   == rhs.m_rd0_wr1    ) &
                  (m_set_index == rhs.m_set_index  ) &
                  (m_way       == rhs.m_way        );
        return(matched);
    endfunction: does_it_match 
endclass: snoop_filter_seq_item

`endif
