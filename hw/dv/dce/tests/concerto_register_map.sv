`ifndef RAL_NCORE
`define RAL_NCORE

import uvm_pkg::*;

class ral_reg_ncore_dce_DIRUIDR extends uvm_reg;
	uvm_reg_field RPN;
	uvm_reg_field NRRI;
	uvm_reg_field NUnitId;
	uvm_reg_field Rsvd1;
	uvm_reg_field Valid;

	function new(string name = "ncore_dce_DIRUIDR");
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

	`uvm_object_utils(ral_reg_ncore_dce_DIRUIDR)

endclass : ral_reg_ncore_dce_DIRUIDR


class ral_reg_ncore_dce_DIRUFUIDR extends uvm_reg;
	uvm_reg_field FUnitId;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUFUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FUnitId = uvm_reg_field::type_id::create("FUnitId",,get_full_name());
      this.FUnitId.configure(this, 16, 0, "RO", 0, 16'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUFUIDR)

endclass : ral_reg_ncore_dce_DIRUFUIDR


class ral_reg_ncore_dce_DIRUTAR extends uvm_reg;
	uvm_reg_field TransActv;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUTAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.TransActv = uvm_reg_field::type_id::create("TransActv",,get_full_name());
      this.TransActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 31, 1, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUTAR)

endclass : ral_reg_ncore_dce_DIRUTAR


class ral_reg_ncore_dce_DIRUSFMCR extends uvm_reg;
	rand uvm_reg_field InitSnoopFilter;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUSFMCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.InitSnoopFilter = uvm_reg_field::type_id::create("InitSnoopFilter",,get_full_name());
      this.InitSnoopFilter.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 31, 1, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUSFMCR)

endclass : ral_reg_ncore_dce_DIRUSFMCR


class ral_reg_ncore_dce_DIRUCECR extends uvm_reg;
	rand uvm_reg_field ErrDetEn;
	rand uvm_reg_field ErrIntEn;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrThreshold;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_dce_DIRUCECR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrDetEn = uvm_reg_field::type_id::create("ErrDetEn",,get_full_name());
      this.ErrDetEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrIntEn = uvm_reg_field::type_id::create("ErrIntEn",,get_full_name());
      this.ErrIntEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.ErrThreshold = uvm_reg_field::type_id::create("ErrThreshold",,get_full_name());
      this.ErrThreshold.configure(this, 8, 4, "RW", 0, 8'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUCECR)

endclass : ral_reg_ncore_dce_DIRUCECR


class ral_reg_ncore_dce_DIRUCESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field ErrCountOverflow;
	uvm_reg_field ErrCount;
	uvm_reg_field Rsvd1;
	uvm_reg_field ErrType;
	uvm_reg_field ErrInfo;

	function new(string name = "ncore_dce_DIRUCESR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
      this.ErrCountOverflow = uvm_reg_field::type_id::create("ErrCountOverflow",,get_full_name());
      this.ErrCountOverflow.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 2, "RO", 0, 8'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 5, 11, "RO", 0, 5'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 16, 16, "RO", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUCESR)

endclass : ral_reg_ncore_dce_DIRUCESR


class ral_reg_ncore_dce_DIRUCELR0 extends uvm_reg;
	rand uvm_reg_field ErrAddr;

	function new(string name = "ncore_dce_DIRUCELR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUCELR0)

endclass : ral_reg_ncore_dce_DIRUCELR0


class ral_reg_ncore_dce_DIRUCELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUCELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUCELR1)

endclass : ral_reg_ncore_dce_DIRUCELR1


class ral_reg_ncore_dce_DIRUCESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrCountOverflow;
	rand uvm_reg_field ErrCount;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrType;
	rand uvm_reg_field ErrInfo;

	function new(string name = "ncore_dce_DIRUCESAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrCountOverflow = uvm_reg_field::type_id::create("ErrCountOverflow",,get_full_name());
      this.ErrCountOverflow.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 2, "RW", 0, 8'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 1, 10, "RO", 0, 1'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 5, 11, "RW", 0, 5'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 16, 16, "RW", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUCESAR)

endclass : ral_reg_ncore_dce_DIRUCESAR


class ral_reg_ncore_dce_DIRUUEDR extends uvm_reg;
	rand uvm_reg_field TransErrDetEn;
	rand uvm_reg_field MemErrDetEn;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUUEDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.TransErrDetEn = uvm_reg_field::type_id::create("TransErrDetEn",,get_full_name());
      this.TransErrDetEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.MemErrDetEn = uvm_reg_field::type_id::create("MemErrDetEn",,get_full_name());
      this.MemErrDetEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 30, 2, "RO", 0, 30'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUUEDR)

endclass : ral_reg_ncore_dce_DIRUUEDR


class ral_reg_ncore_dce_DIRUUEIR extends uvm_reg;
	rand uvm_reg_field TransErrIntEn;
	rand uvm_reg_field MemErrIntEn;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUUEIR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.TransErrIntEn = uvm_reg_field::type_id::create("TransErrIntEn",,get_full_name());
      this.TransErrIntEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.MemErrIntEn = uvm_reg_field::type_id::create("MemErrIntEn",,get_full_name());
      this.MemErrIntEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 30, 2, "RO", 0, 30'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUUEIR)

endclass : ral_reg_ncore_dce_DIRUUEIR


class ral_reg_ncore_dce_DIRUUESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	uvm_reg_field ErrInfo;

	function new(string name = "ncore_dce_DIRUUESR");
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

	`uvm_object_utils(ral_reg_ncore_dce_DIRUUESR)

endclass : ral_reg_ncore_dce_DIRUUESR


class ral_reg_ncore_dce_DIRUUELR0 extends uvm_reg;
	rand uvm_reg_field ErrAddr;

	function new(string name = "ncore_dce_DIRUUELR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUUELR0)

endclass : ral_reg_ncore_dce_DIRUUELR0


class ral_reg_ncore_dce_DIRUUELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUUELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUUELR1)

endclass : ral_reg_ncore_dce_DIRUUELR1


class ral_reg_ncore_dce_DIRUUESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field ErrInfo;

	function new(string name = "ncore_dce_DIRUUESAR");
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

	`uvm_object_utils(ral_reg_ncore_dce_DIRUUESAR)

endclass : ral_reg_ncore_dce_DIRUUESAR


class ral_reg_ncore_dce_DIRUCRTR extends uvm_reg;
	rand uvm_reg_field ResThreshold;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUCRTR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ResThreshold = uvm_reg_field::type_id::create("ResThreshold",,get_full_name());
      this.ResThreshold.configure(this, 8, 0, "RW", 0, 8'h1, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUCRTR)

endclass : ral_reg_ncore_dce_DIRUCRTR


class ral_reg_ncore_dce_DIRUENGIDR extends uvm_reg;
	uvm_reg_field EngVerId;

	function new(string name = "ncore_dce_DIRUENGIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.EngVerId = uvm_reg_field::type_id::create("EngVerId",,get_full_name());
      this.EngVerId.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUENGIDR)

endclass : ral_reg_ncore_dce_DIRUENGIDR


class ral_reg_ncore_dce_DIRUINFOR extends uvm_reg;
	uvm_reg_field ImplVer;
	uvm_reg_field UT;
	uvm_reg_field Rsvd1;
	uvm_reg_field Valid;

	function new(string name = "ncore_dce_DIRUINFOR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ImplVer = uvm_reg_field::type_id::create("ImplVer",,get_full_name());
      this.ImplVer.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
      this.UT = uvm_reg_field::type_id::create("UT",,get_full_name());
      this.UT.configure(this, 4, 8, "RO", 0, 4'h8, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 19, 12, "RO", 0, 19'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUINFOR)

endclass : ral_reg_ncore_dce_DIRUINFOR


class ral_reg_ncore_dce_DIRUGPRAR0 extends uvm_reg;
//	rand uvm_reg_field DIGId;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field HUI;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field Size;
	uvm_reg_field Rsvd3;
	rand uvm_reg_field HUT;
	rand uvm_reg_field Valid;

	function new(string name = "ncore_dce_DIRUGPRAR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
//      this.DIGId = uvm_reg_field::type_id::create("DIGId",,get_full_name());
//      this.DIGId.configure(this, 3, 0, "RW", 0, 3'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 6, 3, "RO", 0, 6'h0, 1, 0, 0);
      this.HUI = uvm_reg_field::type_id::create("HUI",,get_full_name());
      this.HUI.configure(this, 5, 9, "RW", 0, 5'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 6, 14, "RO", 0, 6'h0, 1, 0, 0);
      this.Size = uvm_reg_field::type_id::create("Size",,get_full_name());
      this.Size.configure(this, 5, 20, "RW", 0, 5'h0, 1, 0, 0);
      this.Rsvd3 = uvm_reg_field::type_id::create("Rsvd3",,get_full_name());
      this.Rsvd3.configure(this, 5, 25, "RO", 0, 5'h0, 1, 0, 0);
      this.HUT = uvm_reg_field::type_id::create("HUT",,get_full_name());
      this.HUT.configure(this, 1, 30, "RW", 0, 1'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUGPRAR0)

endclass : ral_reg_ncore_dce_DIRUGPRAR0


class ral_reg_ncore_dce_DIRUGPRAR1 extends uvm_reg;
//	rand uvm_reg_field DIGId;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field HUI;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field Size;
	uvm_reg_field Rsvd3;
	rand uvm_reg_field HUT;
	rand uvm_reg_field Valid;

	function new(string name = "ncore_dce_DIRUGPRAR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
//      this.DIGId = uvm_reg_field::type_id::create("DIGId",,get_full_name());
//      this.DIGId.configure(this, 3, 0, "RW", 0, 3'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 6, 3, "RO", 0, 6'h0, 1, 0, 0);
      this.HUI = uvm_reg_field::type_id::create("HUI",,get_full_name());
      this.HUI.configure(this, 5, 9, "RW", 0, 5'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 6, 14, "RO", 0, 6'h0, 1, 0, 0);
      this.Size = uvm_reg_field::type_id::create("Size",,get_full_name());
      this.Size.configure(this, 5, 20, "RW", 0, 5'h0, 1, 0, 0);
      this.Rsvd3 = uvm_reg_field::type_id::create("Rsvd3",,get_full_name());
      this.Rsvd3.configure(this, 5, 25, "RO", 0, 5'h0, 1, 0, 0);
      this.HUT = uvm_reg_field::type_id::create("HUT",,get_full_name());
      this.HUT.configure(this, 1, 30, "RW", 0, 1'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUGPRAR1)

endclass : ral_reg_ncore_dce_DIRUGPRAR1


class ral_reg_ncore_dce_DIRUGPRBLR0 extends uvm_reg;
	rand uvm_reg_field AddrLow;

	function new(string name = "ncore_dce_DIRUGPRBLR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AddrLow = uvm_reg_field::type_id::create("AddrLow",,get_full_name());
      this.AddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUGPRBLR0)

endclass : ral_reg_ncore_dce_DIRUGPRBLR0


class ral_reg_ncore_dce_DIRUGPRBLR1 extends uvm_reg;
	rand uvm_reg_field AddrLow;

	function new(string name = "ncore_dce_DIRUGPRBLR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AddrLow = uvm_reg_field::type_id::create("AddrLow",,get_full_name());
      this.AddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUGPRBLR1)

endclass : ral_reg_ncore_dce_DIRUGPRBLR1


class ral_reg_ncore_dce_DIRUGPRBHR0 extends uvm_reg;
	rand uvm_reg_field AddrHigh;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUGPRBHR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AddrHigh = uvm_reg_field::type_id::create("AddrHigh",,get_full_name());
      this.AddrHigh.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUGPRBHR0)

endclass : ral_reg_ncore_dce_DIRUGPRBHR0


class ral_reg_ncore_dce_DIRUGPRBHR1 extends uvm_reg;
	rand uvm_reg_field AddrHigh;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUGPRBHR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AddrHigh = uvm_reg_field::type_id::create("AddrHigh",,get_full_name());
      this.AddrHigh.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUGPRBHR1)

endclass : ral_reg_ncore_dce_DIRUGPRBHR1


class ral_reg_ncore_dce_DIRUBRAR extends uvm_reg;
//	rand uvm_reg_field DIGId;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field HUI;
	rand uvm_reg_field HUT;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field Size;
	uvm_reg_field Rsvd3;
	rand uvm_reg_field ST;
	rand uvm_reg_field Valid;

	function new(string name = "ncore_dce_DIRUBRAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
//      this.DIGId = uvm_reg_field::type_id::create("DIGId",,get_full_name());
//      this.DIGId.configure(this, 3, 0, "RW", 0, 3'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 6, 3, "RO", 0, 6'h0, 1, 0, 0);
      this.HUI = uvm_reg_field::type_id::create("HUI",,get_full_name());
      this.HUI.configure(this, 5, 9, "RW", 0, 5'h0, 1, 0, 0);
      this.HUT = uvm_reg_field::type_id::create("HUT",,get_full_name());
      this.HUT.configure(this, 1, 14, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 5, 15, "RO", 0, 5'h0, 1, 0, 0);
      this.Size = uvm_reg_field::type_id::create("Size",,get_full_name());
      this.Size.configure(this, 5, 20, "RW", 0, 5'h0, 1, 0, 0);
      this.Rsvd3 = uvm_reg_field::type_id::create("Rsvd3",,get_full_name());
      this.Rsvd3.configure(this, 5, 25, "RO", 0, 5'h0, 1, 0, 0);
      this.ST = uvm_reg_field::type_id::create("ST",,get_full_name());
      this.ST.configure(this, 1, 30, "RW", 0, 1'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUBRAR)

endclass : ral_reg_ncore_dce_DIRUBRAR


class ral_reg_ncore_dce_DIRUBRBLR extends uvm_reg;
	rand uvm_reg_field AddrLow;

	function new(string name = "ncore_dce_DIRUBRBLR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AddrLow = uvm_reg_field::type_id::create("AddrLow",,get_full_name());
      this.AddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUBRBLR)

endclass : ral_reg_ncore_dce_DIRUBRBLR


class ral_reg_ncore_dce_DIRUBRBHR extends uvm_reg;
	rand uvm_reg_field AddrHigh;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUBRBHR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.AddrHigh = uvm_reg_field::type_id::create("AddrHigh",,get_full_name());
      this.AddrHigh.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUBRBHR)

endclass : ral_reg_ncore_dce_DIRUBRBHR


class ral_reg_ncore_dce_DIRUAMIGR extends uvm_reg;
	rand uvm_reg_field Valid;
	rand uvm_reg_field AMIGS;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_dce_DIRUAMIGR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.AMIGS = uvm_reg_field::type_id::create("AMIGS",,get_full_name());
      this.AMIGS.configure(this, 4, 1, "RW", 0, 4'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 27, 5, "RO", 0, 27'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUAMIGR)

endclass : ral_reg_ncore_dce_DIRUAMIGR


class ral_reg_ncore_dce_DIRUMIFSR extends uvm_reg;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field MIG2AIFId;
	rand uvm_reg_field MIG3AIFId;
	rand uvm_reg_field MIG4AIFId;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_dce_DIRUMIFSR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 6, 0, "RO", 0, 6'h0, 1, 0, 0);
      this.MIG2AIFId = uvm_reg_field::type_id::create("MIG2AIFId",,get_full_name());
      this.MIG2AIFId.configure(this, 3, 6, "RW", 0, 3'h0, 1, 0, 0);
      this.MIG3AIFId = uvm_reg_field::type_id::create("MIG3AIFId",,get_full_name());
      this.MIG3AIFId.configure(this, 3, 9, "RW", 0, 3'h0, 1, 0, 0);
      this.MIG4AIFId = uvm_reg_field::type_id::create("MIG4AIFId",,get_full_name());
      this.MIG4AIFId.configure(this, 3, 12, "RW", 0, 3'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 17, 15, "RO", 0, 17'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUMIFSR)

endclass : ral_reg_ncore_dce_DIRUMIFSR


class ral_reg_ncore_dce_DIRUEDR0 extends uvm_reg;
	rand uvm_reg_field CfgCtrl;

	function new(string name = "ncore_dce_DIRUEDR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CfgCtrl = uvm_reg_field::type_id::create("CfgCtrl",,get_full_name());
      this.CfgCtrl.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_dce_DIRUEDR0)

endclass : ral_reg_ncore_dce_DIRUEDR0


class ral_block_ncore_dce extends uvm_reg_block;
	rand ral_reg_ncore_dce_DIRUIDR DIRUIDR;
	rand ral_reg_ncore_dce_DIRUFUIDR DIRUFUIDR;
	rand ral_reg_ncore_dce_DIRUTAR DIRUTAR;
	rand ral_reg_ncore_dce_DIRUSFMCR DIRUSFMCR;
	rand ral_reg_ncore_dce_DIRUCECR DIRUCECR;
	rand ral_reg_ncore_dce_DIRUCESR DIRUCESR;
	rand ral_reg_ncore_dce_DIRUCELR0 DIRUCELR0;
	rand ral_reg_ncore_dce_DIRUCELR1 DIRUCELR1;
	rand ral_reg_ncore_dce_DIRUCESAR DIRUCESAR;
	rand ral_reg_ncore_dce_DIRUUEDR DIRUUEDR;
	rand ral_reg_ncore_dce_DIRUUEIR DIRUUEIR;
	rand ral_reg_ncore_dce_DIRUUESR DIRUUESR;
	rand ral_reg_ncore_dce_DIRUUELR0 DIRUUELR0;
	rand ral_reg_ncore_dce_DIRUUELR1 DIRUUELR1;
	rand ral_reg_ncore_dce_DIRUUESAR DIRUUESAR;
	rand ral_reg_ncore_dce_DIRUCRTR DIRUCRTR;
	rand ral_reg_ncore_dce_DIRUENGIDR DIRUENGIDR;
	rand ral_reg_ncore_dce_DIRUINFOR DIRUINFOR;
	rand ral_reg_ncore_dce_DIRUGPRAR0 DIRUGPRAR0;
	rand ral_reg_ncore_dce_DIRUGPRAR1 DIRUGPRAR1;
	rand ral_reg_ncore_dce_DIRUGPRBLR0 DIRUGPRBLR0;
	rand ral_reg_ncore_dce_DIRUGPRBLR1 DIRUGPRBLR1;
	rand ral_reg_ncore_dce_DIRUGPRBHR0 DIRUGPRBHR0;
	rand ral_reg_ncore_dce_DIRUGPRBHR1 DIRUGPRBHR1;
	rand ral_reg_ncore_dce_DIRUBRAR DIRUBRAR;
	rand ral_reg_ncore_dce_DIRUBRBLR DIRUBRBLR;
	rand ral_reg_ncore_dce_DIRUBRBHR DIRUBRBHR;
	rand ral_reg_ncore_dce_DIRUAMIGR DIRUAMIGR;
	rand ral_reg_ncore_dce_DIRUMIFSR DIRUMIFSR;
	rand ral_reg_ncore_dce_DIRUEDR0 DIRUEDR0;
	uvm_reg_field DIRUIDR_RPN;
	uvm_reg_field RPN;
	uvm_reg_field DIRUIDR_NRRI;
	uvm_reg_field NRRI;
	uvm_reg_field DIRUIDR_NUnitId;
	uvm_reg_field NUnitId;
	uvm_reg_field DIRUIDR_Rsvd1;
	uvm_reg_field DIRUIDR_Valid;
	uvm_reg_field DIRUFUIDR_FUnitId;
	uvm_reg_field FUnitId;
	uvm_reg_field DIRUFUIDR_Rsvd1;
	uvm_reg_field DIRUTAR_TransActv;
	uvm_reg_field TransActv;
	uvm_reg_field DIRUTAR_Rsvd1;
	rand uvm_reg_field DIRUSFMCR_InitSnoopFilter;
	rand uvm_reg_field InitSnoopFilter;
	uvm_reg_field DIRUSFMCR_Rsvd1;
	rand uvm_reg_field DIRUCECR_ErrDetEn;
	rand uvm_reg_field ErrDetEn;
	rand uvm_reg_field DIRUCECR_ErrIntEn;
	rand uvm_reg_field ErrIntEn;
	uvm_reg_field DIRUCECR_Rsvd1;
	rand uvm_reg_field DIRUCECR_ErrThreshold;
	rand uvm_reg_field ErrThreshold;
	uvm_reg_field DIRUCECR_Rsvd2;
	rand uvm_reg_field DIRUCESR_ErrVld;
	uvm_reg_field DIRUCESR_ErrCountOverflow;
	uvm_reg_field DIRUCESR_ErrCount;
	uvm_reg_field DIRUCESR_Rsvd1;
	uvm_reg_field DIRUCESR_ErrType;
	uvm_reg_field DIRUCESR_ErrInfo;
	rand uvm_reg_field DIRUCELR0_ErrAddr;
	rand uvm_reg_field DIRUCELR1_ErrAddr;
	uvm_reg_field DIRUCELR1_Rsvd1;
	rand uvm_reg_field DIRUCESAR_ErrVld;
	rand uvm_reg_field DIRUCESAR_ErrCountOverflow;
	rand uvm_reg_field DIRUCESAR_ErrCount;
	uvm_reg_field DIRUCESAR_Rsvd1;
	rand uvm_reg_field DIRUCESAR_ErrType;
	rand uvm_reg_field DIRUCESAR_ErrInfo;
	rand uvm_reg_field DIRUUEDR_TransErrDetEn;
	rand uvm_reg_field TransErrDetEn;
	rand uvm_reg_field DIRUUEDR_MemErrDetEn;
	rand uvm_reg_field MemErrDetEn;
	uvm_reg_field DIRUUEDR_Rsvd1;
	rand uvm_reg_field DIRUUEIR_TransErrIntEn;
	rand uvm_reg_field TransErrIntEn;
	rand uvm_reg_field DIRUUEIR_MemErrIntEn;
	rand uvm_reg_field MemErrIntEn;
	uvm_reg_field DIRUUEIR_Rsvd1;
	rand uvm_reg_field DIRUUESR_ErrVld;
	uvm_reg_field DIRUUESR_Rsvd1;
	uvm_reg_field DIRUUESR_ErrType;
	uvm_reg_field DIRUUESR_Rsvd2;
	uvm_reg_field DIRUUESR_ErrInfo;
	rand uvm_reg_field DIRUUELR0_ErrAddr;
	rand uvm_reg_field DIRUUELR1_ErrAddr;
	uvm_reg_field DIRUUELR1_Rsvd1;
	rand uvm_reg_field DIRUUESAR_ErrVld;
	uvm_reg_field DIRUUESAR_Rsvd1;
	rand uvm_reg_field DIRUUESAR_ErrType;
	uvm_reg_field DIRUUESAR_Rsvd2;
	rand uvm_reg_field DIRUUESAR_ErrInfo;
	rand uvm_reg_field DIRUCRTR_ResThreshold;
	rand uvm_reg_field ResThreshold;
	uvm_reg_field DIRUCRTR_Rsvd1;
	uvm_reg_field DIRUENGIDR_EngVerId;
	uvm_reg_field EngVerId;
	uvm_reg_field DIRUINFOR_ImplVer;
	uvm_reg_field ImplVer;
	uvm_reg_field DIRUINFOR_UT;
	uvm_reg_field UT;
	uvm_reg_field DIRUINFOR_Rsvd1;
	uvm_reg_field DIRUINFOR_Valid;
//	rand uvm_reg_field DIRUGPRAR0_DIGId;
	uvm_reg_field DIRUGPRAR0_Rsvd1;
	rand uvm_reg_field DIRUGPRAR0_HUI;
	uvm_reg_field DIRUGPRAR0_Rsvd2;
	rand uvm_reg_field DIRUGPRAR0_Size;
	uvm_reg_field DIRUGPRAR0_Rsvd3;
	rand uvm_reg_field DIRUGPRAR0_HUT;
	rand uvm_reg_field DIRUGPRAR0_Valid;
//	rand uvm_reg_field DIRUGPRAR1_DIGId;
	uvm_reg_field DIRUGPRAR1_Rsvd1;
	rand uvm_reg_field DIRUGPRAR1_HUI;
	uvm_reg_field DIRUGPRAR1_Rsvd2;
	rand uvm_reg_field DIRUGPRAR1_Size;
	uvm_reg_field DIRUGPRAR1_Rsvd3;
	rand uvm_reg_field DIRUGPRAR1_HUT;
	rand uvm_reg_field DIRUGPRAR1_Valid;
	rand uvm_reg_field DIRUGPRBLR0_AddrLow;
	rand uvm_reg_field DIRUGPRBLR1_AddrLow;
	rand uvm_reg_field DIRUGPRBHR0_AddrHigh;
	uvm_reg_field DIRUGPRBHR0_Rsvd1;
	rand uvm_reg_field DIRUGPRBHR1_AddrHigh;
	uvm_reg_field DIRUGPRBHR1_Rsvd1;
//	rand uvm_reg_field DIRUBRAR_DIGId;
	uvm_reg_field DIRUBRAR_Rsvd1;
	rand uvm_reg_field DIRUBRAR_HUI;
	rand uvm_reg_field DIRUBRAR_HUT;
	uvm_reg_field DIRUBRAR_Rsvd2;
	rand uvm_reg_field DIRUBRAR_Size;
	uvm_reg_field DIRUBRAR_Rsvd3;
	rand uvm_reg_field DIRUBRAR_ST;
	rand uvm_reg_field ST;
	rand uvm_reg_field DIRUBRAR_Valid;
	rand uvm_reg_field DIRUBRBLR_AddrLow;
	rand uvm_reg_field DIRUBRBHR_AddrHigh;
	uvm_reg_field DIRUBRBHR_Rsvd1;
	rand uvm_reg_field DIRUAMIGR_Valid;
	rand uvm_reg_field DIRUAMIGR_AMIGS;
	rand uvm_reg_field AMIGS;
	uvm_reg_field DIRUAMIGR_Rsvd1;
	uvm_reg_field DIRUMIFSR_Rsvd1;
	rand uvm_reg_field DIRUMIFSR_MIG2AIFId;
	rand uvm_reg_field MIG2AIFId;
	rand uvm_reg_field DIRUMIFSR_MIG3AIFId;
	rand uvm_reg_field MIG3AIFId;
	rand uvm_reg_field DIRUMIFSR_MIG4AIFId;
	rand uvm_reg_field MIG4AIFId;
	uvm_reg_field DIRUMIFSR_Rsvd2;
	rand uvm_reg_field DIRUEDR0_CfgCtrl;
	rand uvm_reg_field CfgCtrl;

	function new(string name = "ncore_dce");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.DIRUIDR = ral_reg_ncore_dce_DIRUIDR::type_id::create("DIRUIDR",,get_full_name());
      this.DIRUIDR.configure(this, null, "");
      this.DIRUIDR.build();
      this.default_map.add_reg(this.DIRUIDR, `UVM_REG_ADDR_WIDTH'h0, "RO", 0);
		this.DIRUIDR_RPN = this.DIRUIDR.RPN;
		this.RPN = this.DIRUIDR.RPN;
		this.DIRUIDR_NRRI = this.DIRUIDR.NRRI;
		this.NRRI = this.DIRUIDR.NRRI;
		this.DIRUIDR_NUnitId = this.DIRUIDR.NUnitId;
		this.NUnitId = this.DIRUIDR.NUnitId;
		this.DIRUIDR_Rsvd1 = this.DIRUIDR.Rsvd1;
		this.DIRUIDR_Valid = this.DIRUIDR.Valid;
      this.DIRUFUIDR = ral_reg_ncore_dce_DIRUFUIDR::type_id::create("DIRUFUIDR",,get_full_name());
      this.DIRUFUIDR.configure(this, null, "");
      this.DIRUFUIDR.build();
      this.default_map.add_reg(this.DIRUFUIDR, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);
		this.DIRUFUIDR_FUnitId = this.DIRUFUIDR.FUnitId;
		this.FUnitId = this.DIRUFUIDR.FUnitId;
		this.DIRUFUIDR_Rsvd1 = this.DIRUFUIDR.Rsvd1;
      this.DIRUTAR = ral_reg_ncore_dce_DIRUTAR::type_id::create("DIRUTAR",,get_full_name());
      this.DIRUTAR.configure(this, null, "");
      this.DIRUTAR.build();
      this.default_map.add_reg(this.DIRUTAR, `UVM_REG_ADDR_WIDTH'h44, "RO", 0);
		this.DIRUTAR_TransActv = this.DIRUTAR.TransActv;
		this.TransActv = this.DIRUTAR.TransActv;
		this.DIRUTAR_Rsvd1 = this.DIRUTAR.Rsvd1;
      this.DIRUSFMCR = ral_reg_ncore_dce_DIRUSFMCR::type_id::create("DIRUSFMCR",,get_full_name());
      this.DIRUSFMCR.configure(this, null, "");
      this.DIRUSFMCR.build();
      this.default_map.add_reg(this.DIRUSFMCR, `UVM_REG_ADDR_WIDTH'h240, "RW", 0);
		this.DIRUSFMCR_InitSnoopFilter = this.DIRUSFMCR.InitSnoopFilter;
		this.InitSnoopFilter = this.DIRUSFMCR.InitSnoopFilter;
		this.DIRUSFMCR_Rsvd1 = this.DIRUSFMCR.Rsvd1;
      this.DIRUCECR = ral_reg_ncore_dce_DIRUCECR::type_id::create("DIRUCECR",,get_full_name());
      this.DIRUCECR.configure(this, null, "");
      this.DIRUCECR.build();
      this.default_map.add_reg(this.DIRUCECR, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.DIRUCECR_ErrDetEn = this.DIRUCECR.ErrDetEn;
		this.ErrDetEn = this.DIRUCECR.ErrDetEn;
		this.DIRUCECR_ErrIntEn = this.DIRUCECR.ErrIntEn;
		this.ErrIntEn = this.DIRUCECR.ErrIntEn;
		this.DIRUCECR_Rsvd1 = this.DIRUCECR.Rsvd1;
		this.DIRUCECR_ErrThreshold = this.DIRUCECR.ErrThreshold;
		this.ErrThreshold = this.DIRUCECR.ErrThreshold;
		this.DIRUCECR_Rsvd2 = this.DIRUCECR.Rsvd2;
      this.DIRUCESR = ral_reg_ncore_dce_DIRUCESR::type_id::create("DIRUCESR",,get_full_name());
      this.DIRUCESR.configure(this, null, "");
      this.DIRUCESR.build();
      this.default_map.add_reg(this.DIRUCESR, `UVM_REG_ADDR_WIDTH'h104, "RW", 0);
		this.DIRUCESR_ErrVld = this.DIRUCESR.ErrVld;
		this.DIRUCESR_ErrCountOverflow = this.DIRUCESR.ErrCountOverflow;
		this.DIRUCESR_ErrCount = this.DIRUCESR.ErrCount;
		this.DIRUCESR_Rsvd1 = this.DIRUCESR.Rsvd1;
		this.DIRUCESR_ErrType = this.DIRUCESR.ErrType;
		this.DIRUCESR_ErrInfo = this.DIRUCESR.ErrInfo;
      this.DIRUCELR0 = ral_reg_ncore_dce_DIRUCELR0::type_id::create("DIRUCELR0",,get_full_name());
      this.DIRUCELR0.configure(this, null, "");
      this.DIRUCELR0.build();
      this.default_map.add_reg(this.DIRUCELR0, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.DIRUCELR0_ErrAddr = this.DIRUCELR0.ErrAddr;
      this.DIRUCELR1 = ral_reg_ncore_dce_DIRUCELR1::type_id::create("DIRUCELR1",,get_full_name());
      this.DIRUCELR1.configure(this, null, "");
      this.DIRUCELR1.build();
      this.default_map.add_reg(this.DIRUCELR1, `UVM_REG_ADDR_WIDTH'h10C, "RW", 0);
		this.DIRUCELR1_ErrAddr = this.DIRUCELR1.ErrAddr;
		this.DIRUCELR1_Rsvd1 = this.DIRUCELR1.Rsvd1;
      this.DIRUCESAR = ral_reg_ncore_dce_DIRUCESAR::type_id::create("DIRUCESAR",,get_full_name());
      this.DIRUCESAR.configure(this, null, "");
      this.DIRUCESAR.build();
      this.default_map.add_reg(this.DIRUCESAR, `UVM_REG_ADDR_WIDTH'h110, "RW", 0);
		this.DIRUCESAR_ErrVld = this.DIRUCESAR.ErrVld;
		this.DIRUCESAR_ErrCountOverflow = this.DIRUCESAR.ErrCountOverflow;
		this.DIRUCESAR_ErrCount = this.DIRUCESAR.ErrCount;
		this.DIRUCESAR_Rsvd1 = this.DIRUCESAR.Rsvd1;
		this.DIRUCESAR_ErrType = this.DIRUCESAR.ErrType;
		this.DIRUCESAR_ErrInfo = this.DIRUCESAR.ErrInfo;
      this.DIRUUEDR = ral_reg_ncore_dce_DIRUUEDR::type_id::create("DIRUUEDR",,get_full_name());
      this.DIRUUEDR.configure(this, null, "");
      this.DIRUUEDR.build();
      this.default_map.add_reg(this.DIRUUEDR, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.DIRUUEDR_TransErrDetEn = this.DIRUUEDR.TransErrDetEn;
		this.TransErrDetEn = this.DIRUUEDR.TransErrDetEn;
		this.DIRUUEDR_MemErrDetEn = this.DIRUUEDR.MemErrDetEn;
		this.MemErrDetEn = this.DIRUUEDR.MemErrDetEn;
		this.DIRUUEDR_Rsvd1 = this.DIRUUEDR.Rsvd1;
      this.DIRUUEIR = ral_reg_ncore_dce_DIRUUEIR::type_id::create("DIRUUEIR",,get_full_name());
      this.DIRUUEIR.configure(this, null, "");
      this.DIRUUEIR.build();
      this.default_map.add_reg(this.DIRUUEIR, `UVM_REG_ADDR_WIDTH'h144, "RW", 0);
		this.DIRUUEIR_TransErrIntEn = this.DIRUUEIR.TransErrIntEn;
		this.TransErrIntEn = this.DIRUUEIR.TransErrIntEn;
		this.DIRUUEIR_MemErrIntEn = this.DIRUUEIR.MemErrIntEn;
		this.MemErrIntEn = this.DIRUUEIR.MemErrIntEn;
		this.DIRUUEIR_Rsvd1 = this.DIRUUEIR.Rsvd1;
      this.DIRUUESR = ral_reg_ncore_dce_DIRUUESR::type_id::create("DIRUUESR",,get_full_name());
      this.DIRUUESR.configure(this, null, "");
      this.DIRUUESR.build();
      this.default_map.add_reg(this.DIRUUESR, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.DIRUUESR_ErrVld = this.DIRUUESR.ErrVld;
		this.DIRUUESR_Rsvd1 = this.DIRUUESR.Rsvd1;
		this.DIRUUESR_ErrType = this.DIRUUESR.ErrType;
		this.DIRUUESR_Rsvd2 = this.DIRUUESR.Rsvd2;
		this.DIRUUESR_ErrInfo = this.DIRUUESR.ErrInfo;
      this.DIRUUELR0 = ral_reg_ncore_dce_DIRUUELR0::type_id::create("DIRUUELR0",,get_full_name());
      this.DIRUUELR0.configure(this, null, "");
      this.DIRUUELR0.build();
      this.default_map.add_reg(this.DIRUUELR0, `UVM_REG_ADDR_WIDTH'h14C, "RW", 0);
		this.DIRUUELR0_ErrAddr = this.DIRUUELR0.ErrAddr;
      this.DIRUUELR1 = ral_reg_ncore_dce_DIRUUELR1::type_id::create("DIRUUELR1",,get_full_name());
      this.DIRUUELR1.configure(this, null, "");
      this.DIRUUELR1.build();
      this.default_map.add_reg(this.DIRUUELR1, `UVM_REG_ADDR_WIDTH'h150, "RW", 0);
		this.DIRUUELR1_ErrAddr = this.DIRUUELR1.ErrAddr;
		this.DIRUUELR1_Rsvd1 = this.DIRUUELR1.Rsvd1;
      this.DIRUUESAR = ral_reg_ncore_dce_DIRUUESAR::type_id::create("DIRUUESAR",,get_full_name());
      this.DIRUUESAR.configure(this, null, "");
      this.DIRUUESAR.build();
      this.default_map.add_reg(this.DIRUUESAR, `UVM_REG_ADDR_WIDTH'h154, "RW", 0);
		this.DIRUUESAR_ErrVld = this.DIRUUESAR.ErrVld;
		this.DIRUUESAR_Rsvd1 = this.DIRUUESAR.Rsvd1;
		this.DIRUUESAR_ErrType = this.DIRUUESAR.ErrType;
		this.DIRUUESAR_Rsvd2 = this.DIRUUESAR.Rsvd2;
		this.DIRUUESAR_ErrInfo = this.DIRUUESAR.ErrInfo;
      this.DIRUCRTR = ral_reg_ncore_dce_DIRUCRTR::type_id::create("DIRUCRTR",,get_full_name());
      this.DIRUCRTR.configure(this, null, "");
      this.DIRUCRTR.build();
      this.default_map.add_reg(this.DIRUCRTR, `UVM_REG_ADDR_WIDTH'h180, "RW", 0);
		this.DIRUCRTR_ResThreshold = this.DIRUCRTR.ResThreshold;
		this.ResThreshold = this.DIRUCRTR.ResThreshold;
		this.DIRUCRTR_Rsvd1 = this.DIRUCRTR.Rsvd1;
      this.DIRUENGIDR = ral_reg_ncore_dce_DIRUENGIDR::type_id::create("DIRUENGIDR",,get_full_name());
      this.DIRUENGIDR.configure(this, null, "");
      this.DIRUENGIDR.build();
      this.default_map.add_reg(this.DIRUENGIDR, `UVM_REG_ADDR_WIDTH'hFF4, "RO", 0);
		this.DIRUENGIDR_EngVerId = this.DIRUENGIDR.EngVerId;
		this.EngVerId = this.DIRUENGIDR.EngVerId;
      this.DIRUINFOR = ral_reg_ncore_dce_DIRUINFOR::type_id::create("DIRUINFOR",,get_full_name());
      this.DIRUINFOR.configure(this, null, "");
      this.DIRUINFOR.build();
      this.default_map.add_reg(this.DIRUINFOR, `UVM_REG_ADDR_WIDTH'hFFC, "RO", 0);
		this.DIRUINFOR_ImplVer = this.DIRUINFOR.ImplVer;
		this.ImplVer = this.DIRUINFOR.ImplVer;
		this.DIRUINFOR_UT = this.DIRUINFOR.UT;
		this.UT = this.DIRUINFOR.UT;
		this.DIRUINFOR_Rsvd1 = this.DIRUINFOR.Rsvd1;
		this.DIRUINFOR_Valid = this.DIRUINFOR.Valid;
      this.DIRUGPRAR0 = ral_reg_ncore_dce_DIRUGPRAR0::type_id::create("DIRUGPRAR0",,get_full_name());
      this.DIRUGPRAR0.configure(this, null, "");
      this.DIRUGPRAR0.build();
      this.default_map.add_reg(this.DIRUGPRAR0, `UVM_REG_ADDR_WIDTH'h400, "RW", 0);
//		this.DIRUGPRAR0_DIGId = this.DIRUGPRAR0.DIGId;
		this.DIRUGPRAR0_Rsvd1 = this.DIRUGPRAR0.Rsvd1;
		this.DIRUGPRAR0_HUI = this.DIRUGPRAR0.HUI;
		this.DIRUGPRAR0_Rsvd2 = this.DIRUGPRAR0.Rsvd2;
		this.DIRUGPRAR0_Size = this.DIRUGPRAR0.Size;
		this.DIRUGPRAR0_Rsvd3 = this.DIRUGPRAR0.Rsvd3;
		this.DIRUGPRAR0_HUT = this.DIRUGPRAR0.HUT;
		this.DIRUGPRAR0_Valid = this.DIRUGPRAR0.Valid;
      this.DIRUGPRAR1 = ral_reg_ncore_dce_DIRUGPRAR1::type_id::create("DIRUGPRAR1",,get_full_name());
      this.DIRUGPRAR1.configure(this, null, "");
      this.DIRUGPRAR1.build();
      this.default_map.add_reg(this.DIRUGPRAR1, `UVM_REG_ADDR_WIDTH'h410, "RW", 0);
//		this.DIRUGPRAR1_DIGId = this.DIRUGPRAR1.DIGId;
		this.DIRUGPRAR1_Rsvd1 = this.DIRUGPRAR1.Rsvd1;
		this.DIRUGPRAR1_HUI = this.DIRUGPRAR1.HUI;
		this.DIRUGPRAR1_Rsvd2 = this.DIRUGPRAR1.Rsvd2;
		this.DIRUGPRAR1_Size = this.DIRUGPRAR1.Size;
		this.DIRUGPRAR1_Rsvd3 = this.DIRUGPRAR1.Rsvd3;
		this.DIRUGPRAR1_HUT = this.DIRUGPRAR1.HUT;
		this.DIRUGPRAR1_Valid = this.DIRUGPRAR1.Valid;
      this.DIRUGPRBLR0 = ral_reg_ncore_dce_DIRUGPRBLR0::type_id::create("DIRUGPRBLR0",,get_full_name());
      this.DIRUGPRBLR0.configure(this, null, "");
      this.DIRUGPRBLR0.build();
      this.default_map.add_reg(this.DIRUGPRBLR0, `UVM_REG_ADDR_WIDTH'h404, "RW", 0);
		this.DIRUGPRBLR0_AddrLow = this.DIRUGPRBLR0.AddrLow;
      this.DIRUGPRBLR1 = ral_reg_ncore_dce_DIRUGPRBLR1::type_id::create("DIRUGPRBLR1",,get_full_name());
      this.DIRUGPRBLR1.configure(this, null, "");
      this.DIRUGPRBLR1.build();
      this.default_map.add_reg(this.DIRUGPRBLR1, `UVM_REG_ADDR_WIDTH'h414, "RW", 0);
		this.DIRUGPRBLR1_AddrLow = this.DIRUGPRBLR1.AddrLow;
      this.DIRUGPRBHR0 = ral_reg_ncore_dce_DIRUGPRBHR0::type_id::create("DIRUGPRBHR0",,get_full_name());
      this.DIRUGPRBHR0.configure(this, null, "");
      this.DIRUGPRBHR0.build();
      this.default_map.add_reg(this.DIRUGPRBHR0, `UVM_REG_ADDR_WIDTH'h408, "RW", 0);
		this.DIRUGPRBHR0_AddrHigh = this.DIRUGPRBHR0.AddrHigh;
		this.DIRUGPRBHR0_Rsvd1 = this.DIRUGPRBHR0.Rsvd1;
      this.DIRUGPRBHR1 = ral_reg_ncore_dce_DIRUGPRBHR1::type_id::create("DIRUGPRBHR1",,get_full_name());
      this.DIRUGPRBHR1.configure(this, null, "");
      this.DIRUGPRBHR1.build();
      this.default_map.add_reg(this.DIRUGPRBHR1, `UVM_REG_ADDR_WIDTH'h418, "RW", 0);
		this.DIRUGPRBHR1_AddrHigh = this.DIRUGPRBHR1.AddrHigh;
		this.DIRUGPRBHR1_Rsvd1 = this.DIRUGPRBHR1.Rsvd1;
      this.DIRUBRAR = ral_reg_ncore_dce_DIRUBRAR::type_id::create("DIRUBRAR",,get_full_name());
      this.DIRUBRAR.configure(this, null, "");
      this.DIRUBRAR.build();
      this.default_map.add_reg(this.DIRUBRAR, `UVM_REG_ADDR_WIDTH'h3A0, "RW", 0);
//		this.DIRUBRAR_DIGId = this.DIRUBRAR.DIGId;
		this.DIRUBRAR_Rsvd1 = this.DIRUBRAR.Rsvd1;
		this.DIRUBRAR_HUI = this.DIRUBRAR.HUI;
		this.DIRUBRAR_HUT = this.DIRUBRAR.HUT;
		this.DIRUBRAR_Rsvd2 = this.DIRUBRAR.Rsvd2;
		this.DIRUBRAR_Size = this.DIRUBRAR.Size;
		this.DIRUBRAR_Rsvd3 = this.DIRUBRAR.Rsvd3;
		this.DIRUBRAR_ST = this.DIRUBRAR.ST;
		this.ST = this.DIRUBRAR.ST;
		this.DIRUBRAR_Valid = this.DIRUBRAR.Valid;
      this.DIRUBRBLR = ral_reg_ncore_dce_DIRUBRBLR::type_id::create("DIRUBRBLR",,get_full_name());
      this.DIRUBRBLR.configure(this, null, "");
      this.DIRUBRBLR.build();
      this.default_map.add_reg(this.DIRUBRBLR, `UVM_REG_ADDR_WIDTH'h3A4, "RW", 0);
		this.DIRUBRBLR_AddrLow = this.DIRUBRBLR.AddrLow;
      this.DIRUBRBHR = ral_reg_ncore_dce_DIRUBRBHR::type_id::create("DIRUBRBHR",,get_full_name());
      this.DIRUBRBHR.configure(this, null, "");
      this.DIRUBRBHR.build();
      this.default_map.add_reg(this.DIRUBRBHR, `UVM_REG_ADDR_WIDTH'h3A8, "RW", 0);
		this.DIRUBRBHR_AddrHigh = this.DIRUBRBHR.AddrHigh;
		this.DIRUBRBHR_Rsvd1 = this.DIRUBRBHR.Rsvd1;
      this.DIRUAMIGR = ral_reg_ncore_dce_DIRUAMIGR::type_id::create("DIRUAMIGR",,get_full_name());
      this.DIRUAMIGR.configure(this, null, "");
      this.DIRUAMIGR.build();
      this.default_map.add_reg(this.DIRUAMIGR, `UVM_REG_ADDR_WIDTH'h3C0, "RW", 0);
		this.DIRUAMIGR_Valid = this.DIRUAMIGR.Valid;
		this.DIRUAMIGR_AMIGS = this.DIRUAMIGR.AMIGS;
		this.AMIGS = this.DIRUAMIGR.AMIGS;
		this.DIRUAMIGR_Rsvd1 = this.DIRUAMIGR.Rsvd1;
      this.DIRUMIFSR = ral_reg_ncore_dce_DIRUMIFSR::type_id::create("DIRUMIFSR",,get_full_name());
      this.DIRUMIFSR.configure(this, null, "");
      this.DIRUMIFSR.build();
      this.default_map.add_reg(this.DIRUMIFSR, `UVM_REG_ADDR_WIDTH'h3C4, "RW", 0);
		this.DIRUMIFSR_Rsvd1 = this.DIRUMIFSR.Rsvd1;
		this.DIRUMIFSR_MIG2AIFId = this.DIRUMIFSR.MIG2AIFId;
		this.MIG2AIFId = this.DIRUMIFSR.MIG2AIFId;
		this.DIRUMIFSR_MIG3AIFId = this.DIRUMIFSR.MIG3AIFId;
		this.MIG3AIFId = this.DIRUMIFSR.MIG3AIFId;
		this.DIRUMIFSR_MIG4AIFId = this.DIRUMIFSR.MIG4AIFId;
		this.MIG4AIFId = this.DIRUMIFSR.MIG4AIFId;
		this.DIRUMIFSR_Rsvd2 = this.DIRUMIFSR.Rsvd2;
      this.DIRUEDR0 = ral_reg_ncore_dce_DIRUEDR0::type_id::create("DIRUEDR0",,get_full_name());
      this.DIRUEDR0.configure(this, null, "");
      this.DIRUEDR0.build();
      this.default_map.add_reg(this.DIRUEDR0, `UVM_REG_ADDR_WIDTH'hA00, "RW", 0);
		this.DIRUEDR0_CfgCtrl = this.DIRUEDR0.CfgCtrl;
		this.CfgCtrl = this.DIRUEDR0.CfgCtrl;
   endfunction : build

	`uvm_object_utils(ral_block_ncore_dce)

endclass : ral_block_ncore_dce


class ral_sys_ncore extends uvm_reg_block;

   rand ral_block_ncore_dce dce;

	function new(string name = "ncore");
		super.new(name);
	endfunction: new

	function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.dce = ral_block_ncore_dce::type_id::create("dce",,get_full_name());
      this.dce.configure(this, "");
      this.dce.build();
      this.default_map.add_submap(this.dce.default_map, `UVM_REG_ADDR_WIDTH'h0);
	endfunction : build

	`uvm_object_utils(ral_sys_ncore)
endclass : ral_sys_ncore



`endif
