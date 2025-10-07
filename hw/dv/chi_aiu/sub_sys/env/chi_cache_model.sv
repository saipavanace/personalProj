class chi_cache_model extends uvm_object;
    `uvm_object_utils(chi_cache_model)

    chi_txn_memory txn_mem;

    function new (string name="chi_comparator", uvm_component parent=null);
        super.new (name, parent);
        // txn_mem = chi_txn_memory::get_instance();
    endfunction

endclass: chi_cache_model