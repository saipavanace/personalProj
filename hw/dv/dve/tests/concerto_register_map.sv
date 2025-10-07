`ifndef RAL_NCORE
`define RAL_NCORE

import uvm_pkg::*;

class ral_reg_ncore_dve_DVEUIDR extends uvm_reg;
	uvm_reg_field RPN;
	uvm_reg_field NRRI;
	uvm_reg_field NUnitId;
	uvm_reg_field Rsvd1;
	uvm_reg_field Valid;

	function new(string name = "ncore_dve_DVEUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.RPN = uvm_reg_field::type_id::create("RPN",,get_full_name());
      this.RPN.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
      this.NRRI = uvm_reg_field::type_id::create("NRRI",,get_full_name());
      this.NRRI.configure(this, 4, 8, "RO", 0, 4'h0, 1, 0, 0);
      this.NUnitId = uvm_reg_field::type_id::create("NUnitId",,get_full_name());
      this.NUnitId.configure(this, 12, 12, "RO", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 7, 24, "RO", 0, 7'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUIDR)

endclass : ral_reg_ncore_dve_DVEUIDR


class ral_reg_ncore_dve_DVEUFUIDR extends uvm_reg;
	uvm_reg_field FUnitId;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dve_DVEUFUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FUnitId = uvm_reg_field::type_id::create("FUnitId",,get_full_name());
      this.FUnitId.configure(this, 16, 0, "RO", 0, 16'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUFUIDR)

endclass : ral_reg_ncore_dve_DVEUFUIDR


class ral_reg_ncore_dve_DVEUSER0 extends uvm_reg;
	rand uvm_reg_field SnpsEnb;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dve_DVEUSER0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SnpsEnb = uvm_reg_field::type_id::create("SnpsEnb",,get_full_name());
      this.SnpsEnb.configure(this, 8, 0, "RW", 0, 8'hff, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUSER0)

endclass : ral_reg_ncore_dve_DVEUSER0


class ral_reg_ncore_dve_DVEUUEDR extends uvm_reg;
	rand uvm_reg_field ProtErrDetEn;
	rand uvm_reg_field MemErrDetEn;
	rand uvm_reg_field TransErrDetEn;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dve_DVEUUEDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ProtErrDetEn = uvm_reg_field::type_id::create("ProtErrDetEn",,get_full_name());
      this.ProtErrDetEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.TransErrDetEn = uvm_reg_field::type_id::create("TransErrDetEn",,get_full_name());
      this.TransErrDetEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.MemErrDetEn = uvm_reg_field::type_id::create("MemErrDetEn",,get_full_name());
      this.MemErrDetEn.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 29, 3, "RO", 0, 29'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUUEDR)

endclass : ral_reg_ncore_dve_DVEUUEDR


class ral_reg_ncore_dve_DVEUUEIR extends uvm_reg;
	rand uvm_reg_field ProtErrIntEn;
	rand uvm_reg_field MemErrIntEn;
	rand uvm_reg_field TransErrIntEn;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dve_DVEUUEIR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ProtErrIntEn = uvm_reg_field::type_id::create("ProtErrIntEn",,get_full_name());
      this.ProtErrIntEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.TransErrIntEn = uvm_reg_field::type_id::create("TransErrIntEn",,get_full_name());
      this.TransErrIntEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.MemErrIntEn = uvm_reg_field::type_id::create("MemErrIntEn",,get_full_name());
      this.MemErrIntEn.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 29, 3, "RO", 0, 29'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUUEIR)

endclass : ral_reg_ncore_dve_DVEUUEIR


class ral_reg_ncore_dve_DVEUUESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	uvm_reg_field ErrInfo;

	function new(string name = "ncore_dve_DVEUUESR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 3, 1, "RO", 0, 3'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 5, 4, "RO", 0, 5'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 7, 9, "RO", 0, 7'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUUESR)

endclass : ral_reg_ncore_dve_DVEUUESR


class ral_reg_ncore_dve_DVEUUELR0 extends uvm_reg;
	rand uvm_reg_field ErrAddr;

	function new(string name = "ncore_dve_DVEUUELR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 31, 0, "RW", 0, 32'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUUELR0)

endclass : ral_reg_ncore_dve_DVEUUELR0


class ral_reg_ncore_dve_DVEUUELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dve_DVEUUELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUUELR1)

endclass : ral_reg_ncore_dve_DVEUUELR1


class ral_reg_ncore_dve_DVEUUESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field ErrInfo;

	function new(string name = "ncore_dve_DVEUUESAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 3, 1, "RO", 0, 3'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 5, 4, "RW", 0, 5'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 7, 9, "RO", 0, 7'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 16, 16, "RW", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUUESAR)

endclass : ral_reg_ncore_dve_DVEUUESAR


class ral_reg_ncore_dve_DVEUCRTR extends uvm_reg;
	rand uvm_reg_field ResThreshold;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dve_DVEUCRTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ResThreshold = uvm_reg_field::type_id::create("ResThreshold",,get_full_name());
      this.ResThreshold.configure(this, 8, 0, "RW", 0, 8'h1, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUCRTR)

endclass : ral_reg_ncore_dve_DVEUCRTR


class ral_reg_ncore_dve_DVEUENGIDR extends uvm_reg;
	uvm_reg_field EngVerId;

	function new(string name = "ncore_dve_DVEUENGIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.EngVerId = uvm_reg_field::type_id::create("EngVerId",,get_full_name());
      this.EngVerId.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUENGIDR)

endclass : ral_reg_ncore_dve_DVEUENGIDR


class ral_reg_ncore_dve_DVEUINFOR extends uvm_reg;
	uvm_reg_field ImplVer;
	uvm_reg_field UT;
	uvm_reg_field Rsvd1;
	uvm_reg_field Valid;

	function new(string name = "ncore_dve_DVEUINFOR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ImplVer = uvm_reg_field::type_id::create("ImplVer",,get_full_name());
      this.ImplVer.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
      this.UT = uvm_reg_field::type_id::create("UT",,get_full_name());
      this.UT.configure(this, 4, 8, "RO", 0, 4'hb, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 19, 12, "RO", 0, 19'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dve_DVEUINFOR)

endclass : ral_reg_ncore_dve_DVEUINFOR


class ral_block_ncore_dve extends uvm_reg_block;
	rand ral_reg_ncore_dve_DVEUIDR DVEUIDR;
	rand ral_reg_ncore_dve_DVEUFUIDR DVEUFUIDR;
	rand ral_reg_ncore_dve_DVEUSER0 DVEUSER0;
	rand ral_reg_ncore_dve_DVEUUEDR DVEUUEDR;
	rand ral_reg_ncore_dve_DVEUUEIR DVEUUEIR;
	rand ral_reg_ncore_dve_DVEUUESR DVEUUESR;
	rand ral_reg_ncore_dve_DVEUUELR0 DVEUUELR0;
	rand ral_reg_ncore_dve_DVEUUELR1 DVEUUELR1;
	rand ral_reg_ncore_dve_DVEUUESAR DVEUUESAR;
	rand ral_reg_ncore_dve_DVEUCRTR DVEUCRTR;
	rand ral_reg_ncore_dve_DVEUENGIDR DVEUENGIDR;
	rand ral_reg_ncore_dve_DVEUINFOR DVEUINFOR;
	uvm_reg_field DVEUIDR_RPN;
	uvm_reg_field RPN;
	uvm_reg_field DVEUIDR_NRRI;
	uvm_reg_field NRRI;
	uvm_reg_field DVEUIDR_NUnitId;
	uvm_reg_field NUnitId;
	uvm_reg_field DVEUIDR_Rsvd1;
	uvm_reg_field DVEUIDR_Valid;
	uvm_reg_field DVEUFUIDR_FUnitId;
	uvm_reg_field FUnitId;
	uvm_reg_field DVEUFUIDR_Rsvd1;
	rand uvm_reg_field DVEUSER0_SnpsEnb;
	rand uvm_reg_field SnpsEnb;
	uvm_reg_field DVEUSER0_Rsvd1;
	rand uvm_reg_field DVEUUEDR_ProtErrDetEn;
	rand uvm_reg_field ProtErrDetEn;
	rand uvm_reg_field DVEUUEDR_MemErrDetEn;
	rand uvm_reg_field MemErrDetEn;
	rand uvm_reg_field DVEUUEDR_TransErrDetEn;
	rand uvm_reg_field TransErrDetEn;
	uvm_reg_field DVEUUEDR_Rsvd1;
	rand uvm_reg_field DVEUUEIR_ProtErrIntEn;
	rand uvm_reg_field ProtErrIntEn;
	rand uvm_reg_field DVEUUEIR_MemErrIntEn;
	rand uvm_reg_field MemErrIntEn;
	rand uvm_reg_field DVEUUEIR_TransErrIntEn;
	rand uvm_reg_field TransErrIntEn;
	uvm_reg_field DVEUUEIR_Rsvd1;
	rand uvm_reg_field DVEUUESR_ErrVld;
	uvm_reg_field DVEUUESR_Rsvd1;
	uvm_reg_field DVEUUESR_ErrType;
	uvm_reg_field DVEUUESR_Rsvd2;
	uvm_reg_field DVEUUESR_ErrInfo;
	rand uvm_reg_field DVEUUELR0_ErrAddr;
	rand uvm_reg_field ErrAddr0;
	rand uvm_reg_field DVEUUELR1_ErrAddr;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field DVEUUELR1_Rsvd1;
	rand uvm_reg_field DVEUUESAR_ErrVld;
	uvm_reg_field DVEUUESAR_Rsvd1;
	rand uvm_reg_field DVEUUESAR_ErrType;
	uvm_reg_field DVEUUESAR_Rsvd2;
	rand uvm_reg_field DVEUUESAR_ErrInfo;
	rand uvm_reg_field DVEUCRTR_ResThreshold;
	rand uvm_reg_field ResThreshold;
	uvm_reg_field DVEUCRTR_Rsvd1;
	uvm_reg_field DVEUENGIDR_EngVerId;
	uvm_reg_field EngVerId;
	uvm_reg_field DVEUINFOR_ImplVer;
	uvm_reg_field ImplVer;
	uvm_reg_field DVEUINFOR_UT;
	uvm_reg_field UT;
	uvm_reg_field DVEUINFOR_Rsvd1;
	uvm_reg_field DVEUINFOR_Valid;

	function new(string name = "ncore_dve");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.DVEUIDR = ral_reg_ncore_dve_DVEUIDR::type_id::create("DVEUIDR",,get_full_name());
      this.DVEUIDR.configure(this, null, "");
      this.DVEUIDR.build();
      this.default_map.add_reg(this.DVEUIDR, `UVM_REG_ADDR_WIDTH'h0, "RO", 0);
		this.DVEUIDR_RPN = this.DVEUIDR.RPN;
		this.RPN = this.DVEUIDR.RPN;
		this.DVEUIDR_NRRI = this.DVEUIDR.NRRI;
		this.NRRI = this.DVEUIDR.NRRI;
		this.DVEUIDR_NUnitId = this.DVEUIDR.NUnitId;
		this.NUnitId = this.DVEUIDR.NUnitId;
		this.DVEUIDR_Rsvd1 = this.DVEUIDR.Rsvd1;
		this.DVEUIDR_Valid = this.DVEUIDR.Valid;
      this.DVEUFUIDR = ral_reg_ncore_dve_DVEUFUIDR::type_id::create("DVEUFUIDR",,get_full_name());
      this.DVEUFUIDR.configure(this, null, "");
      this.DVEUFUIDR.build();
      this.default_map.add_reg(this.DVEUFUIDR, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);
		this.DVEUFUIDR_FUnitId = this.DVEUFUIDR.FUnitId;
		this.FUnitId = this.DVEUFUIDR.FUnitId;
		this.DVEUFUIDR_Rsvd1 = this.DVEUFUIDR.Rsvd1;
      this.DVEUSER0 = ral_reg_ncore_dve_DVEUSER0::type_id::create("DVEUSER0",,get_full_name());
      this.DVEUSER0.configure(this, null, "");
      this.DVEUSER0.build();
      this.default_map.add_reg(this.DVEUSER0, `UVM_REG_ADDR_WIDTH'h400, "RW", 0);
		this.DVEUSER0_SnpsEnb = this.DVEUSER0.SnpsEnb;
		this.SnpsEnb = this.DVEUSER0.SnpsEnb;
		this.DVEUSER0_Rsvd1 = this.DVEUSER0.Rsvd1;
      this.DVEUUEDR = ral_reg_ncore_dve_DVEUUEDR::type_id::create("DVEUUEDR",,get_full_name());
      this.DVEUUEDR.configure(this, null, "");
      this.DVEUUEDR.build();
      this.default_map.add_reg(this.DVEUUEDR, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.DVEUUEDR_ProtErrDetEn = this.DVEUUEDR.ProtErrDetEn;
		this.ProtErrDetEn = this.DVEUUEDR.ProtErrDetEn;
		this.DVEUUEDR_MemErrDetEn = this.DVEUUEDR.MemErrDetEn;
		this.MemErrDetEn = this.DVEUUEDR.MemErrDetEn;
		this.DVEUUEDR_TransErrDetEn = this.DVEUUEDR.TransErrDetEn;
		this.TransErrDetEn = this.DVEUUEDR.TransErrDetEn;
		this.DVEUUEDR_Rsvd1 = this.DVEUUEDR.Rsvd1;
      this.DVEUUEIR = ral_reg_ncore_dve_DVEUUEIR::type_id::create("DVEUUEIR",,get_full_name());
      this.DVEUUEIR.configure(this, null, "");
      this.DVEUUEIR.build();
      this.default_map.add_reg(this.DVEUUEIR, `UVM_REG_ADDR_WIDTH'h144, "RW", 0);
		this.DVEUUEIR_ProtErrIntEn = this.DVEUUEIR.ProtErrIntEn;
		this.ProtErrIntEn = this.DVEUUEIR.ProtErrIntEn;
		this.DVEUUEIR_MemErrIntEn = this.DVEUUEIR.MemErrIntEn;
		this.MemErrIntEn = this.DVEUUEIR.MemErrIntEn;
		this.DVEUUEIR_TransErrIntEn = this.DVEUUEIR.TransErrIntEn;
		this.TransErrIntEn = this.DVEUUEIR.TransErrIntEn;
		this.DVEUUEIR_Rsvd1 = this.DVEUUEIR.Rsvd1;
      this.DVEUUESR = ral_reg_ncore_dve_DVEUUESR::type_id::create("DVEUUESR",,get_full_name());
      this.DVEUUESR.configure(this, null, "");
      this.DVEUUESR.build();
      this.default_map.add_reg(this.DVEUUESR, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.DVEUUESR_ErrVld = this.DVEUUESR.ErrVld;
		this.DVEUUESR_Rsvd1 = this.DVEUUESR.Rsvd1;
		this.DVEUUESR_ErrType = this.DVEUUESR.ErrType;
		this.DVEUUESR_Rsvd2 = this.DVEUUESR.Rsvd2;
		this.DVEUUESR_ErrInfo = this.DVEUUESR.ErrInfo;
      this.DVEUUELR0 = ral_reg_ncore_dve_DVEUUELR0::type_id::create("DVEUUELR0",,get_full_name());
      this.DVEUUELR0.configure(this, null, "");
      this.DVEUUELR0.build();
      this.default_map.add_reg(this.DVEUUELR0, `UVM_REG_ADDR_WIDTH'h14C, "RW", 0);
		this.DVEUUELR0_ErrAddr = this.DVEUUELR0.ErrAddr;
		this.ErrAddr0 = this.DVEUUELR0.ErrAddr;
      this.DVEUUELR1 = ral_reg_ncore_dve_DVEUUELR1::type_id::create("DVEUUELR1",,get_full_name());
      this.DVEUUELR1.configure(this, null, "");
      this.DVEUUELR1.build();
      this.default_map.add_reg(this.DVEUUELR1, `UVM_REG_ADDR_WIDTH'h150, "RW", 0);
		this.DVEUUELR1_ErrAddr = this.DVEUUELR1.ErrAddr;
		this.ErrAddr = this.DVEUUELR1.ErrAddr;
		this.DVEUUELR1_Rsvd1 = this.DVEUUELR1.Rsvd1;
      this.DVEUUESAR = ral_reg_ncore_dve_DVEUUESAR::type_id::create("DVEUUESAR",,get_full_name());
      this.DVEUUESAR.configure(this, null, "");
      this.DVEUUESAR.build();
      this.default_map.add_reg(this.DVEUUESAR, `UVM_REG_ADDR_WIDTH'h154, "RW", 0);
		this.DVEUUESAR_ErrVld = this.DVEUUESAR.ErrVld;
		this.DVEUUESAR_Rsvd1 = this.DVEUUESAR.Rsvd1;
		this.DVEUUESAR_ErrType = this.DVEUUESAR.ErrType;
		this.DVEUUESAR_Rsvd2 = this.DVEUUESAR.Rsvd2;
		this.DVEUUESAR_ErrInfo = this.DVEUUESAR.ErrInfo;
      this.DVEUCRTR = ral_reg_ncore_dve_DVEUCRTR::type_id::create("DVEUCRTR",,get_full_name());
      this.DVEUCRTR.configure(this, null, "");
      this.DVEUCRTR.build();
      this.default_map.add_reg(this.DVEUCRTR, `UVM_REG_ADDR_WIDTH'h180, "RW", 0);
		this.DVEUCRTR_ResThreshold = this.DVEUCRTR.ResThreshold;
		this.ResThreshold = this.DVEUCRTR.ResThreshold;
		this.DVEUCRTR_Rsvd1 = this.DVEUCRTR.Rsvd1;
      this.DVEUENGIDR = ral_reg_ncore_dve_DVEUENGIDR::type_id::create("DVEUENGIDR",,get_full_name());
      this.DVEUENGIDR.configure(this, null, "");
      this.DVEUENGIDR.build();
      this.default_map.add_reg(this.DVEUENGIDR, `UVM_REG_ADDR_WIDTH'hFF4, "RO", 0);
		this.DVEUENGIDR_EngVerId = this.DVEUENGIDR.EngVerId;
		this.EngVerId = this.DVEUENGIDR.EngVerId;
      this.DVEUINFOR = ral_reg_ncore_dve_DVEUINFOR::type_id::create("DVEUINFOR",,get_full_name());
      this.DVEUINFOR.configure(this, null, "");
      this.DVEUINFOR.build();
      this.default_map.add_reg(this.DVEUINFOR, `UVM_REG_ADDR_WIDTH'hFFC, "RO", 0);
		this.DVEUINFOR_ImplVer = this.DVEUINFOR.ImplVer;
		this.ImplVer = this.DVEUINFOR.ImplVer;
		this.DVEUINFOR_UT = this.DVEUINFOR.UT;
		this.UT = this.DVEUINFOR.UT;
		this.DVEUINFOR_Rsvd1 = this.DVEUINFOR.Rsvd1;
		this.DVEUINFOR_Valid = this.DVEUINFOR.Valid;
   endfunction : build

	`uvm_object_utils(ral_block_ncore_dve)

endclass : ral_block_ncore_dve


class ral_sys_ncore extends uvm_reg_block;

   rand ral_block_ncore_dve dve;

	function new(string name = "ncore");
		super.new(name);
	endfunction: new

	function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.dve = ral_block_ncore_dve::type_id::create("dve",,get_full_name());
      this.dve.configure(this, "");
      this.dve.build();
      this.default_map.add_submap(this.dve.default_map, `UVM_REG_ADDR_WIDTH'h0);
	endfunction : build

	`uvm_object_utils(ral_sys_ncore)
endclass : ral_sys_ncore



`endif
