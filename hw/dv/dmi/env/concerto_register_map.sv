class concerto_register_map extends uvm_reg_block;

   rand ral_block_concerto_registers_Coherent_Memory_Interface_Unit cmiu;

	function new(string name = "concerto_register_map");
		super.new(name);
	endfunction: new

	function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.cmiu = ral_block_concerto_registers_Coherent_Memory_Interface_Unit::type_id::create("cmiu",,get_full_name());
      this.cmiu.configure(this, "");
      this.cmiu.build();
      this.default_map.add_submap(this.cmiu.default_map, `UVM_REG_ADDR_WIDTH'h0);
	endfunction : build

	`uvm_object_utils(concerto_register_map)
endclass : concerto_register_map
