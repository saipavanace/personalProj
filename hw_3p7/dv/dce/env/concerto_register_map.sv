
`ifndef RAL_DIRECTORY_MAP
`define RAL_DIRECTORY_MAP

//
//Integrating Register maps
//

class concerto_dce_register_map extends uvm_reg_block;

   rand ral_block_concerto_registers_Directory_Unit      dce;
   //rand ral_block_concerto_registers_Coherent_Subsystem  sys;

   `uvm_object_utils(concerto_dce_register_map)

   function new(string name = "concerto_dce_register_map");
	super.new(name);
   endfunction: new

   function void build();
      this.default_map = create_map("",'h80000, 4, UVM_LITTLE_ENDIAN, 0);
      this.dce = ral_block_concerto_registers_Directory_Unit::type_id::create("dce",,get_full_name());
      this.dce.configure(this, "");
      this.dce.build();
      this.default_map.add_submap(this.dce.default_map, `UVM_REG_ADDR_WIDTH'h0);

      //this.default_map = create_map("", 'hFF000, 4, UVM_LITTLE_ENDIAN, 0);
      //this.sys = ral_block_concerto_registers_Coherent_Subsystem::type_id::create("sys",,get_full_name());
      //this.sys.configure(this, "");
      //this.sys.build();
      //this.default_map.add_submap(this.sys.default_map, `UVM_REG_ADDR_WIDTH'h0);

   endfunction : build

endclass : concerto_dce_register_map

class concerto_sys_register_map extends uvm_reg_block;

   rand ral_block_concerto_registers_Coherent_Subsystem  sys;

   `uvm_object_utils(concerto_sys_register_map)

   function new(string name = "concerto_sys_register_map");
	super.new(name);
   endfunction: new

   function void build();

      this.default_map = create_map("", 'hFF000, 4, UVM_LITTLE_ENDIAN, 0);
      this.sys = ral_block_concerto_registers_Coherent_Subsystem::type_id::create("sys",,get_full_name());
      this.sys.configure(this, "");
      this.sys.build();
      this.default_map.add_submap(this.sys.default_map, `UVM_REG_ADDR_WIDTH'h0);

   endfunction : build

endclass : concerto_sys_register_map


`endif
