class chi_txn_memory extends uvm_object;
    //`uvm_object_param_utils(chi_txn_memory)

    static local chi_txn_memory m_mem;

    txn_info m_txn_q[$];

    protected function new(string name="chi_txn_memory");
        super.new(name);
    endfunction: new

    static function chi_txn_memory get_instance();
        if (m_mem == null) begin
            m_mem = new();
        end
        return m_mem;
    endfunction: get_instance
    
endclass: chi_txn_memory
