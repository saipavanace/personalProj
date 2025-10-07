`ifndef RAL_COHERENT_SUBSYSTEM
`define RAL_COHERENT_SUBSYSTEM

import uvm_pkg::*;

class ral_reg_concerto_registers_Coherent_Subsystem_CSADSER extends uvm_reg;
	rand uvm_reg_field DvmSnpEn;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSER");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpEn = uvm_reg_field::type_id::create("DvmSnpEn",,get_full_name());
      this.DvmSnpEn.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSER)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSER


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR extends uvm_reg;
	uvm_reg_field DvmSnpActv;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpActv = uvm_reg_field::type_id::create("DvmSnpActv",,get_full_name());
      this.DvmSnpActv.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR


class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR


class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR


class ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR extends uvm_reg;
	rand uvm_reg_field CSSFIDR;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSSFIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CSSFIDR = uvm_reg_field::type_id::create("CSSFIDR",,get_full_name());
      this.CSSFIDR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
      this.CSSFIDR.set_reset('h0, "SOFT");
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR


class ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR extends uvm_reg;
	rand uvm_reg_field CSUIDR;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CSUIDR = uvm_reg_field::type_id::create("CSUIDR",,get_full_name());
      this.CSUIDR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
      this.CSUIDR.set_reset('h0, "SOFT");
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR


class ral_reg_concerto_registers_Coherent_Subsystem_CSIDR extends uvm_reg;
	rand uvm_reg_field CSIDR;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CSIDR = uvm_reg_field::type_id::create("CSIDR",,get_full_name());
      this.CSIDR.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
      this.CSIDR.set_reset('h0, "SOFT");
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSIDR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSIDR


class ral_block_concerto_registers_Coherent_Subsystem extends uvm_reg_block;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSER CSADSER;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR CSADSAR;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR CSCEISR;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR CSUEISR;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR CSSFIDR;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR CSUIDR;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSIDR CSIDR;
	rand uvm_reg_field CSADSER_DvmSnpEn;
	rand uvm_reg_field DvmSnpEn;
	uvm_reg_field CSADSAR_DvmSnpActv;
	uvm_reg_field DvmSnpActv;
	uvm_reg_field CSCEISR_ErrIntVld;
	uvm_reg_field CSUEISR_ErrIntVld;
	rand uvm_reg_field CSSFIDR_CSSFIDR;
	rand uvm_reg_field CSUIDR_CSUIDR;
	rand uvm_reg_field CSIDR_CSIDR;

	function new(string name = "concerto_registers_Coherent_Subsystem");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.CSADSER = ral_reg_concerto_registers_Coherent_Subsystem_CSADSER::type_id::create("CSADSER",,get_full_name());
      this.CSADSER.configure(this, null, "");
      this.CSADSER.build();
      this.default_map.add_reg(this.CSADSER, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
		this.CSADSER_DvmSnpEn = this.CSADSER.DvmSnpEn;
		this.DvmSnpEn = this.CSADSER.DvmSnpEn;
      this.CSADSAR = ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR::type_id::create("CSADSAR",,get_full_name());
      this.CSADSAR.configure(this, null, "");
      this.CSADSAR.build();
      this.default_map.add_reg(this.CSADSAR, `UVM_REG_ADDR_WIDTH'h50, "RO", 0);
		this.CSADSAR_DvmSnpActv = this.CSADSAR.DvmSnpActv;
		this.DvmSnpActv = this.CSADSAR.DvmSnpActv;
      this.CSCEISR = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR::type_id::create("CSCEISR",,get_full_name());
      this.CSCEISR.configure(this, null, "");
      this.CSCEISR.build();
      this.default_map.add_reg(this.CSCEISR, `UVM_REG_ADDR_WIDTH'h100, "RO", 0);
		this.CSCEISR_ErrIntVld = this.CSCEISR.ErrIntVld;
      this.CSUEISR = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR::type_id::create("CSUEISR",,get_full_name());
      this.CSUEISR.configure(this, null, "");
      this.CSUEISR.build();
      this.default_map.add_reg(this.CSUEISR, `UVM_REG_ADDR_WIDTH'h140, "RO", 0);
		this.CSUEISR_ErrIntVld = this.CSUEISR.ErrIntVld;
      this.CSSFIDR = ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR::type_id::create("CSSFIDR",,get_full_name());
      this.CSSFIDR.configure(this, null, "");
      this.CSSFIDR.build();
      this.default_map.add_reg(this.CSSFIDR, `UVM_REG_ADDR_WIDTH'hF00, "RW", 0);
		this.CSSFIDR_CSSFIDR = this.CSSFIDR.CSSFIDR;
      this.CSUIDR = ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR::type_id::create("CSUIDR",,get_full_name());
      this.CSUIDR.configure(this, null, "");
      this.CSUIDR.build();
      this.default_map.add_reg(this.CSUIDR, `UVM_REG_ADDR_WIDTH'hFF8, "RW", 0);
		this.CSUIDR_CSUIDR = this.CSUIDR.CSUIDR;
      this.CSIDR = ral_reg_concerto_registers_Coherent_Subsystem_CSIDR::type_id::create("CSIDR",,get_full_name());
      this.CSIDR.configure(this, null, "");
      this.CSIDR.build();
      this.default_map.add_reg(this.CSIDR, `UVM_REG_ADDR_WIDTH'hFFC, "RW", 0);
		this.CSIDR_CSIDR = this.CSIDR.CSIDR;
   endfunction : build

	`uvm_object_utils(ral_block_concerto_registers_Coherent_Subsystem)

endclass : ral_block_concerto_registers_Coherent_Subsystem



`endif
