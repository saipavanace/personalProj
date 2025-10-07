class common_knob_list;

    local static common_knob_list m_list;
    static common_knob_class m_list_of_knobs [string];

    local function new();
    endfunction: new

    static function common_knob_list get_instance();
        if (m_list == null) begin
            m_list = new();
        end
        return m_list;
    endfunction : get_instance

    function void print();
        string m_tmp;
        m_list_of_knobs.first(m_tmp);
        `uvm_info("Common Knob List", "**** LIST OF KNOBS REGISTERED TO COMMON KNOB CLASS ***", UVM_NONE)
        do begin
            `uvm_info("", $sformatf("%s", m_list_of_knobs[m_tmp].convert2string()), UVM_NONE)
        end while (m_list_of_knobs.next(m_tmp)); 
        `uvm_info("Common Knob List", "**** END LIST OF KNOBS REGISTERED TO COMMON KNOB CLASS ***", UVM_NONE)
    endfunction : print

endclass : common_knob_list
