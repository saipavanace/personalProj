`ifndef RAL_DIRECTORY_UNIT
`define RAL_DIRECTORY_UNIT

import uvm_pkg::*;

class ral_reg_concerto_registers_Directory_Unit_DIRUTCR extends uvm_reg;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUTCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUTCR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUTCR


class ral_reg_concerto_registers_Directory_Unit_DIRUTAR extends uvm_reg;
	uvm_reg_field TransActv;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUTAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.TransActv = uvm_reg_field::type_id::create("TransActv",,get_full_name());
      this.TransActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 31, 1, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUTAR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUTAR


class ral_reg_concerto_registers_Directory_Unit_DIRUSFER extends uvm_reg;
	rand uvm_reg_field SfEn;

	function new(string name = "concerto_registers_Directory_Unit_DIRUSFER");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SfEn = uvm_reg_field::type_id::create("SfEn",,get_full_name());
      this.SfEn.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUSFER)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUSFER


class ral_reg_concerto_registers_Directory_Unit_DIRUCASER extends uvm_reg;
	rand uvm_reg_field CaSnpEn;

	function new(string name = "concerto_registers_Directory_Unit_DIRUCASER");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CaSnpEn = uvm_reg_field::type_id::create("CaSnpEn",,get_full_name());
      this.CaSnpEn.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUCASER)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUCASER


class ral_reg_concerto_registers_Directory_Unit_DIRUCASAR extends uvm_reg;
	uvm_reg_field CaSnpActv;

	function new(string name = "concerto_registers_Directory_Unit_DIRUCASAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.CaSnpActv = uvm_reg_field::type_id::create("CaSnpActv",,get_full_name());
      this.CaSnpActv.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUCASAR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUCASAR


class ral_reg_concerto_registers_Directory_Unit_DIRUMRHER extends uvm_reg;
	rand uvm_reg_field MrHntEn;

	function new(string name = "concerto_registers_Directory_Unit_DIRUMRHER");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MrHntEn = uvm_reg_field::type_id::create("MrHntEn",,get_full_name());
      this.MrHntEn.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUMRHER)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUMRHER


class ral_reg_concerto_registers_Directory_Unit_DIRUSFMCR extends uvm_reg;
	rand uvm_reg_field SfMntOp;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field SfId;
	rand uvm_reg_field SfSecAttr;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Directory_Unit_DIRUSFMCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.SfMntOp = uvm_reg_field::type_id::create("SfMntOp",,get_full_name());
      this.SfMntOp.configure(this, 4, 0, "RW", 0, 4'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 12, 4, "RO", 0, 12'h0, 1, 0, 0);
      this.SfId = uvm_reg_field::type_id::create("SfId",,get_full_name());
      this.SfId.configure(this, 5, 16, "RW", 0, 5'h0, 1, 0, 0);
      this.SfSecAttr = uvm_reg_field::type_id::create("SfSecAttr",,get_full_name());
      this.SfSecAttr.configure(this, 1, 21, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 10, 22, "RO", 0, 10'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUSFMCR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUSFMCR


class ral_reg_concerto_registers_Directory_Unit_DIRUSFMAR extends uvm_reg;
	uvm_reg_field MntOpActv;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUSFMAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntOpActv = uvm_reg_field::type_id::create("MntOpActv",,get_full_name());
      this.MntOpActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 31, 1, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUSFMAR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUSFMAR


class ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR0 extends uvm_reg;
	rand uvm_reg_field MntSet;
	rand uvm_reg_field MntWay;
	rand uvm_reg_field MntWord;

	function new(string name = "concerto_registers_Directory_Unit_DIRUSFMLR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntSet = uvm_reg_field::type_id::create("MntSet",,get_full_name());
      this.MntSet.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
      this.MntWay = uvm_reg_field::type_id::create("MntWay",,get_full_name());
      this.MntWay.configure(this, 6, 20, "RW", 0, 6'h0, 1, 0, 0);
      this.MntWord = uvm_reg_field::type_id::create("MntWord",,get_full_name());
      this.MntWord.configure(this, 6, 26, "RW", 0, 6'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR0)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR0


class ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR1 extends uvm_reg;
	rand uvm_reg_field MntAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUSFMLR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntAddr = uvm_reg_field::type_id::create("MntAddr",,get_full_name());
      this.MntAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR1)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR1


class ral_reg_concerto_registers_Directory_Unit_DIRUSFMDR extends uvm_reg;
	rand uvm_reg_field MntData;

	function new(string name = "concerto_registers_Directory_Unit_DIRUSFMDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntData = uvm_reg_field::type_id::create("MntData",,get_full_name());
      this.MntData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUSFMDR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUSFMDR


class ral_reg_concerto_registers_Directory_Unit_DIRUCECR extends uvm_reg;
	rand uvm_reg_field ErrDetEn;
	rand uvm_reg_field ErrIntEn;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrThreshold;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Directory_Unit_DIRUCECR");
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

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUCECR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUCECR


class ral_reg_concerto_registers_Directory_Unit_DIRUCESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	uvm_reg_field Rsvd1;
	uvm_reg_field ErrCount;
	uvm_reg_field ErrType;
	uvm_reg_field ErrInfo;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Directory_Unit_DIRUCESR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RO", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RO", 0, 8'h0, 1, 0, 1);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUCESR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUCESR


class ral_reg_concerto_registers_Directory_Unit_DIRUCELR0 extends uvm_reg;
	rand uvm_reg_field ErrEntry;
	rand uvm_reg_field ErrWay;
	rand uvm_reg_field ErrWord;

	function new(string name = "concerto_registers_Directory_Unit_DIRUCELR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrEntry = uvm_reg_field::type_id::create("ErrEntry",,get_full_name());
      this.ErrEntry.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
      this.ErrWay = uvm_reg_field::type_id::create("ErrWay",,get_full_name());
      this.ErrWay.configure(this, 6, 20, "RW", 0, 6'h0, 1, 0, 0);
      this.ErrWord = uvm_reg_field::type_id::create("ErrWord",,get_full_name());
      this.ErrWord.configure(this, 6, 26, "RW", 0, 6'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUCELR0)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUCELR0


class ral_reg_concerto_registers_Directory_Unit_DIRUCELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUCELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUCELR1)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUCELR1


class ral_reg_concerto_registers_Directory_Unit_DIRUCESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrCount;
	rand uvm_reg_field ErrType;
	rand uvm_reg_field ErrInfo;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Directory_Unit_DIRUCESAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RW", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RW", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUCESAR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUCESAR


class ral_reg_concerto_registers_Directory_Unit_DIRUUECR extends uvm_reg;
	rand uvm_reg_field ErrDetEn;
	rand uvm_reg_field ErrIntEn;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrThreshold;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Directory_Unit_DIRUUECR");
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

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUUECR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUUECR


class ral_reg_concerto_registers_Directory_Unit_DIRUUESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	uvm_reg_field Rsvd1;
	uvm_reg_field ErrCount;
	uvm_reg_field ErrType;
	uvm_reg_field ErrInfo;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Directory_Unit_DIRUUESR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "W1C", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "W1C", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RO", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RO", 0, 8'h0, 1, 0, 1);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUUESR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUUESR


class ral_reg_concerto_registers_Directory_Unit_DIRUUELR0 extends uvm_reg;
	rand uvm_reg_field ErrEntry;
	rand uvm_reg_field ErrWay;
	rand uvm_reg_field ErrWord;

	function new(string name = "concerto_registers_Directory_Unit_DIRUUELR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrEntry = uvm_reg_field::type_id::create("ErrEntry",,get_full_name());
      this.ErrEntry.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
      this.ErrWay = uvm_reg_field::type_id::create("ErrWay",,get_full_name());
      this.ErrWay.configure(this, 6, 20, "RW", 0, 6'h0, 1, 0, 0);
      this.ErrWord = uvm_reg_field::type_id::create("ErrWord",,get_full_name());
      this.ErrWord.configure(this, 6, 26, "RW", 0, 6'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUUELR0)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUUELR0


class ral_reg_concerto_registers_Directory_Unit_DIRUUELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUUELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUUELR1)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUUELR1


class ral_reg_concerto_registers_Directory_Unit_DIRUUESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrCount;
	rand uvm_reg_field ErrType;
	rand uvm_reg_field ErrInfo;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Directory_Unit_DIRUUESAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RW", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RW", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUUESAR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUUESAR


class ral_reg_concerto_registers_Directory_Unit_DIRUDCR extends uvm_reg;
	rand uvm_reg_field DbgOp;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUDCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DbgOp = uvm_reg_field::type_id::create("DbgOp",,get_full_name());
      this.DbgOp.configure(this, 4, 0, "RW", 0, 4'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 28, 4, "RO", 0, 28'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUDCR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUDCR


class ral_reg_concerto_registers_Directory_Unit_DIRUDAR extends uvm_reg;
	uvm_reg_field DbgOpActv;
	uvm_reg_field DbgOpFail;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUDAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DbgOpActv = uvm_reg_field::type_id::create("DbgOpActv",,get_full_name());
      this.DbgOpActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.DbgOpFail = uvm_reg_field::type_id::create("DbgOpFail",,get_full_name());
      this.DbgOpFail.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 30, 2, "RO", 0, 30'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUDAR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUDAR


class ral_reg_concerto_registers_Directory_Unit_DIRUDLR extends uvm_reg;
	rand uvm_reg_field DbgEntry;
	rand uvm_reg_field DbgStruct;
	rand uvm_reg_field DbgWord;

	function new(string name = "concerto_registers_Directory_Unit_DIRUDLR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DbgEntry = uvm_reg_field::type_id::create("DbgEntry",,get_full_name());
      this.DbgEntry.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
      this.DbgStruct = uvm_reg_field::type_id::create("DbgStruct",,get_full_name());
      this.DbgStruct.configure(this, 6, 20, "RW", 0, 6'h0, 1, 0, 0);
      this.DbgWord = uvm_reg_field::type_id::create("DbgWord",,get_full_name());
      this.DbgWord.configure(this, 6, 26, "RW", 0, 6'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUDLR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUDLR


class ral_reg_concerto_registers_Directory_Unit_DIRUDDR extends uvm_reg;
	uvm_reg_field DbgData;

	function new(string name = "concerto_registers_Directory_Unit_DIRUDDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DbgData = uvm_reg_field::type_id::create("DbgData",,get_full_name());
      this.DbgData.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUDDR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUDDR


class ral_reg_concerto_registers_Directory_Unit_DIRUDFR extends uvm_reg;
	rand uvm_reg_field DIRUDFR;

	function new(string name = "concerto_registers_Directory_Unit_DIRUDFR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DIRUDFR = uvm_reg_field::type_id::create("DIRUDFR",,get_full_name());
      this.DIRUDFR.configure(this, 32, 0, "RW", 0, 32'h0, 0, 0, 1);
      this.DIRUDFR.set_reset('h0, "SOFT");
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUDFR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUDFR


class ral_reg_concerto_registers_Directory_Unit_DIRUIDR extends uvm_reg;
	uvm_reg_field ImplVer;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit_DIRUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ImplVer = uvm_reg_field::type_id::create("ImplVer",,get_full_name());
      this.ImplVer.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Directory_Unit_DIRUIDR)

endclass : ral_reg_concerto_registers_Directory_Unit_DIRUIDR


class ral_block_concerto_registers_Directory_Unit extends uvm_reg_block;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUTCR DIRUTCR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUTAR DIRUTAR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUSFER DIRUSFER;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUCASER DIRUCASER;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUCASAR DIRUCASAR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUMRHER DIRUMRHER;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUSFMCR DIRUSFMCR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUSFMAR DIRUSFMAR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR0 DIRUSFMLR0;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR1 DIRUSFMLR1;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUSFMDR DIRUSFMDR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUCECR DIRUCECR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUCESR DIRUCESR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUCELR0 DIRUCELR0;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUCELR1 DIRUCELR1;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUCESAR DIRUCESAR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUUECR DIRUUECR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUUESR DIRUUESR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUUELR0 DIRUUELR0;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUUELR1 DIRUUELR1;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUUESAR DIRUUESAR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUDCR DIRUDCR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUDAR DIRUDAR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUDLR DIRUDLR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUDDR DIRUDDR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUDFR DIRUDFR;
	rand ral_reg_concerto_registers_Directory_Unit_DIRUIDR DIRUIDR;
	uvm_reg_field DIRUTCR_Rsvd1;
	uvm_reg_field DIRUTAR_TransActv;
	uvm_reg_field TransActv;
	uvm_reg_field DIRUTAR_Rsvd1;
	rand uvm_reg_field DIRUSFER_SfEn;
	rand uvm_reg_field SfEn;
	rand uvm_reg_field DIRUCASER_CaSnpEn;
	rand uvm_reg_field CaSnpEn;
	uvm_reg_field DIRUCASAR_CaSnpActv;
	uvm_reg_field CaSnpActv;
	rand uvm_reg_field DIRUMRHER_MrHntEn;
	rand uvm_reg_field MrHntEn;
	rand uvm_reg_field DIRUSFMCR_SfMntOp;
	rand uvm_reg_field SfMntOp;
	uvm_reg_field DIRUSFMCR_Rsvd1;
	rand uvm_reg_field DIRUSFMCR_SfId;
	rand uvm_reg_field SfId;
	rand uvm_reg_field DIRUSFMCR_SfSecAttr;
	rand uvm_reg_field SfSecAttr;
	uvm_reg_field DIRUSFMCR_Rsvd2;
	uvm_reg_field DIRUSFMAR_MntOpActv;
	uvm_reg_field MntOpActv;
	uvm_reg_field DIRUSFMAR_Rsvd1;
	rand uvm_reg_field DIRUSFMLR0_MntSet;
	rand uvm_reg_field MntSet;
	rand uvm_reg_field DIRUSFMLR0_MntWay;
	rand uvm_reg_field MntWay;
	rand uvm_reg_field DIRUSFMLR0_MntWord;
	rand uvm_reg_field MntWord;
	rand uvm_reg_field DIRUSFMLR1_MntAddr;
	rand uvm_reg_field MntAddr;
	uvm_reg_field DIRUSFMLR1_Rsvd1;
	rand uvm_reg_field DIRUSFMDR_MntData;
	rand uvm_reg_field MntData;
	rand uvm_reg_field DIRUCECR_ErrDetEn;
	rand uvm_reg_field DIRUCECR_ErrIntEn;
	uvm_reg_field DIRUCECR_Rsvd1;
	rand uvm_reg_field DIRUCECR_ErrThreshold;
	uvm_reg_field DIRUCECR_Rsvd2;
	rand uvm_reg_field DIRUCESR_ErrVld;
	rand uvm_reg_field DIRUCESR_ErrOvf;
	uvm_reg_field DIRUCESR_Rsvd1;
	uvm_reg_field DIRUCESR_ErrCount;
	uvm_reg_field DIRUCESR_ErrType;
	uvm_reg_field DIRUCESR_ErrInfo;
	uvm_reg_field DIRUCESR_Rsvd2;
	rand uvm_reg_field DIRUCELR0_ErrEntry;
	rand uvm_reg_field DIRUCELR0_ErrWay;
	rand uvm_reg_field DIRUCELR0_ErrWord;
	rand uvm_reg_field DIRUCELR1_ErrAddr;
	uvm_reg_field DIRUCELR1_Rsvd1;
	rand uvm_reg_field DIRUCESAR_ErrVld;
	rand uvm_reg_field DIRUCESAR_ErrOvf;
	uvm_reg_field DIRUCESAR_Rsvd1;
	rand uvm_reg_field DIRUCESAR_ErrCount;
	rand uvm_reg_field DIRUCESAR_ErrType;
	rand uvm_reg_field DIRUCESAR_ErrInfo;
	uvm_reg_field DIRUCESAR_Rsvd2;
	rand uvm_reg_field DIRUUECR_ErrDetEn;
	rand uvm_reg_field DIRUUECR_ErrIntEn;
	uvm_reg_field DIRUUECR_Rsvd1;
	rand uvm_reg_field DIRUUECR_ErrThreshold;
	uvm_reg_field DIRUUECR_Rsvd2;
	rand uvm_reg_field DIRUUESR_ErrVld;
	rand uvm_reg_field DIRUUESR_ErrOvf;
	uvm_reg_field DIRUUESR_Rsvd1;
	uvm_reg_field DIRUUESR_ErrCount;
	uvm_reg_field DIRUUESR_ErrType;
	uvm_reg_field DIRUUESR_ErrInfo;
	uvm_reg_field DIRUUESR_Rsvd2;
	rand uvm_reg_field DIRUUELR0_ErrEntry;
	rand uvm_reg_field DIRUUELR0_ErrWay;
	rand uvm_reg_field DIRUUELR0_ErrWord;
	rand uvm_reg_field DIRUUELR1_ErrAddr;
	uvm_reg_field DIRUUELR1_Rsvd1;
	rand uvm_reg_field DIRUUESAR_ErrVld;
	rand uvm_reg_field DIRUUESAR_ErrOvf;
	uvm_reg_field DIRUUESAR_Rsvd1;
	rand uvm_reg_field DIRUUESAR_ErrCount;
	rand uvm_reg_field DIRUUESAR_ErrType;
	rand uvm_reg_field DIRUUESAR_ErrInfo;
	uvm_reg_field DIRUUESAR_Rsvd2;
	rand uvm_reg_field DIRUDCR_DbgOp;
	rand uvm_reg_field DbgOp;
	uvm_reg_field DIRUDCR_Rsvd1;
	uvm_reg_field DIRUDAR_DbgOpActv;
	uvm_reg_field DbgOpActv;
	uvm_reg_field DIRUDAR_DbgOpFail;
	uvm_reg_field DbgOpFail;
	uvm_reg_field DIRUDAR_Rsvd1;
	rand uvm_reg_field DIRUDLR_DbgEntry;
	rand uvm_reg_field DbgEntry;
	rand uvm_reg_field DIRUDLR_DbgStruct;
	rand uvm_reg_field DbgStruct;
	rand uvm_reg_field DIRUDLR_DbgWord;
	rand uvm_reg_field DbgWord;
	uvm_reg_field DIRUDDR_DbgData;
	uvm_reg_field DbgData;
	rand uvm_reg_field DIRUDFR_DIRUDFR;
	uvm_reg_field DIRUIDR_ImplVer;
	uvm_reg_field ImplVer;
	uvm_reg_field DIRUIDR_Rsvd1;

	function new(string name = "concerto_registers_Directory_Unit");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.DIRUTCR = ral_reg_concerto_registers_Directory_Unit_DIRUTCR::type_id::create("DIRUTCR",,get_full_name());
      this.DIRUTCR.configure(this, null, "");
      this.DIRUTCR.build();
      this.default_map.add_reg(this.DIRUTCR, `UVM_REG_ADDR_WIDTH'h0, "RO", 0);
		this.DIRUTCR_Rsvd1 = this.DIRUTCR.Rsvd1;
      this.DIRUTAR = ral_reg_concerto_registers_Directory_Unit_DIRUTAR::type_id::create("DIRUTAR",,get_full_name());
      this.DIRUTAR.configure(this, null, "");
      this.DIRUTAR.build();
      this.default_map.add_reg(this.DIRUTAR, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);
		this.DIRUTAR_TransActv = this.DIRUTAR.TransActv;
		this.TransActv = this.DIRUTAR.TransActv;
		this.DIRUTAR_Rsvd1 = this.DIRUTAR.Rsvd1;
      this.DIRUSFER = ral_reg_concerto_registers_Directory_Unit_DIRUSFER::type_id::create("DIRUSFER",,get_full_name());
      this.DIRUSFER.configure(this, null, "");
      this.DIRUSFER.build();
      this.default_map.add_reg(this.DIRUSFER, `UVM_REG_ADDR_WIDTH'h10, "RW", 0);
		this.DIRUSFER_SfEn = this.DIRUSFER.SfEn;
		this.SfEn = this.DIRUSFER.SfEn;
      this.DIRUCASER = ral_reg_concerto_registers_Directory_Unit_DIRUCASER::type_id::create("DIRUCASER",,get_full_name());
      this.DIRUCASER.configure(this, null, "");
      this.DIRUCASER.build();
      this.default_map.add_reg(this.DIRUCASER, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
		this.DIRUCASER_CaSnpEn = this.DIRUCASER.CaSnpEn;
		this.CaSnpEn = this.DIRUCASER.CaSnpEn;
      this.DIRUCASAR = ral_reg_concerto_registers_Directory_Unit_DIRUCASAR::type_id::create("DIRUCASAR",,get_full_name());
      this.DIRUCASAR.configure(this, null, "");
      this.DIRUCASAR.build();
      this.default_map.add_reg(this.DIRUCASAR, `UVM_REG_ADDR_WIDTH'h50, "RO", 0);
		this.DIRUCASAR_CaSnpActv = this.DIRUCASAR.CaSnpActv;
		this.CaSnpActv = this.DIRUCASAR.CaSnpActv;
      this.DIRUMRHER = ral_reg_concerto_registers_Directory_Unit_DIRUMRHER::type_id::create("DIRUMRHER",,get_full_name());
      this.DIRUMRHER.configure(this, null, "");
      this.DIRUMRHER.build();
      this.default_map.add_reg(this.DIRUMRHER, `UVM_REG_ADDR_WIDTH'h70, "RW", 0);
		this.DIRUMRHER_MrHntEn = this.DIRUMRHER.MrHntEn;
		this.MrHntEn = this.DIRUMRHER.MrHntEn;
      this.DIRUSFMCR = ral_reg_concerto_registers_Directory_Unit_DIRUSFMCR::type_id::create("DIRUSFMCR",,get_full_name());
      this.DIRUSFMCR.configure(this, null, "");
      this.DIRUSFMCR.build();
      this.default_map.add_reg(this.DIRUSFMCR, `UVM_REG_ADDR_WIDTH'h80, "RW", 0);
		this.DIRUSFMCR_SfMntOp = this.DIRUSFMCR.SfMntOp;
		this.SfMntOp = this.DIRUSFMCR.SfMntOp;
		this.DIRUSFMCR_Rsvd1 = this.DIRUSFMCR.Rsvd1;
		this.DIRUSFMCR_SfId = this.DIRUSFMCR.SfId;
		this.SfId = this.DIRUSFMCR.SfId;
		this.DIRUSFMCR_SfSecAttr = this.DIRUSFMCR.SfSecAttr;
		this.SfSecAttr = this.DIRUSFMCR.SfSecAttr;
		this.DIRUSFMCR_Rsvd2 = this.DIRUSFMCR.Rsvd2;
      this.DIRUSFMAR = ral_reg_concerto_registers_Directory_Unit_DIRUSFMAR::type_id::create("DIRUSFMAR",,get_full_name());
      this.DIRUSFMAR.configure(this, null, "");
      this.DIRUSFMAR.build();
      this.default_map.add_reg(this.DIRUSFMAR, `UVM_REG_ADDR_WIDTH'h84, "RO", 0);
		this.DIRUSFMAR_MntOpActv = this.DIRUSFMAR.MntOpActv;
		this.MntOpActv = this.DIRUSFMAR.MntOpActv;
		this.DIRUSFMAR_Rsvd1 = this.DIRUSFMAR.Rsvd1;
      this.DIRUSFMLR0 = ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR0::type_id::create("DIRUSFMLR0",,get_full_name());
      this.DIRUSFMLR0.configure(this, null, "");
      this.DIRUSFMLR0.build();
      this.default_map.add_reg(this.DIRUSFMLR0, `UVM_REG_ADDR_WIDTH'h88, "RW", 0);
		this.DIRUSFMLR0_MntSet = this.DIRUSFMLR0.MntSet;
		this.MntSet = this.DIRUSFMLR0.MntSet;
		this.DIRUSFMLR0_MntWay = this.DIRUSFMLR0.MntWay;
		this.MntWay = this.DIRUSFMLR0.MntWay;
		this.DIRUSFMLR0_MntWord = this.DIRUSFMLR0.MntWord;
		this.MntWord = this.DIRUSFMLR0.MntWord;
      this.DIRUSFMLR1 = ral_reg_concerto_registers_Directory_Unit_DIRUSFMLR1::type_id::create("DIRUSFMLR1",,get_full_name());
      this.DIRUSFMLR1.configure(this, null, "");
      this.DIRUSFMLR1.build();
      this.default_map.add_reg(this.DIRUSFMLR1, `UVM_REG_ADDR_WIDTH'h8C, "RW", 0);
		this.DIRUSFMLR1_MntAddr = this.DIRUSFMLR1.MntAddr;
		this.MntAddr = this.DIRUSFMLR1.MntAddr;
		this.DIRUSFMLR1_Rsvd1 = this.DIRUSFMLR1.Rsvd1;
      this.DIRUSFMDR = ral_reg_concerto_registers_Directory_Unit_DIRUSFMDR::type_id::create("DIRUSFMDR",,get_full_name());
      this.DIRUSFMDR.configure(this, null, "");
      this.DIRUSFMDR.build();
      this.default_map.add_reg(this.DIRUSFMDR, `UVM_REG_ADDR_WIDTH'h90, "RW", 0);
		this.DIRUSFMDR_MntData = this.DIRUSFMDR.MntData;
		this.MntData = this.DIRUSFMDR.MntData;
      this.DIRUCECR = ral_reg_concerto_registers_Directory_Unit_DIRUCECR::type_id::create("DIRUCECR",,get_full_name());
      this.DIRUCECR.configure(this, null, "");
      this.DIRUCECR.build();
      this.default_map.add_reg(this.DIRUCECR, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.DIRUCECR_ErrDetEn = this.DIRUCECR.ErrDetEn;
		this.DIRUCECR_ErrIntEn = this.DIRUCECR.ErrIntEn;
		this.DIRUCECR_Rsvd1 = this.DIRUCECR.Rsvd1;
		this.DIRUCECR_ErrThreshold = this.DIRUCECR.ErrThreshold;
		this.DIRUCECR_Rsvd2 = this.DIRUCECR.Rsvd2;
      this.DIRUCESR = ral_reg_concerto_registers_Directory_Unit_DIRUCESR::type_id::create("DIRUCESR",,get_full_name());
      this.DIRUCESR.configure(this, null, "");
      this.DIRUCESR.build();
      this.default_map.add_reg(this.DIRUCESR, `UVM_REG_ADDR_WIDTH'h104, "RW", 0);
		this.DIRUCESR_ErrVld = this.DIRUCESR.ErrVld;
		this.DIRUCESR_ErrOvf = this.DIRUCESR.ErrOvf;
		this.DIRUCESR_Rsvd1 = this.DIRUCESR.Rsvd1;
		this.DIRUCESR_ErrCount = this.DIRUCESR.ErrCount;
		this.DIRUCESR_ErrType = this.DIRUCESR.ErrType;
		this.DIRUCESR_ErrInfo = this.DIRUCESR.ErrInfo;
		this.DIRUCESR_Rsvd2 = this.DIRUCESR.Rsvd2;
      this.DIRUCELR0 = ral_reg_concerto_registers_Directory_Unit_DIRUCELR0::type_id::create("DIRUCELR0",,get_full_name());
      this.DIRUCELR0.configure(this, null, "");
      this.DIRUCELR0.build();
      this.default_map.add_reg(this.DIRUCELR0, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.DIRUCELR0_ErrEntry = this.DIRUCELR0.ErrEntry;
		this.DIRUCELR0_ErrWay = this.DIRUCELR0.ErrWay;
		this.DIRUCELR0_ErrWord = this.DIRUCELR0.ErrWord;
      this.DIRUCELR1 = ral_reg_concerto_registers_Directory_Unit_DIRUCELR1::type_id::create("DIRUCELR1",,get_full_name());
      this.DIRUCELR1.configure(this, null, "");
      this.DIRUCELR1.build();
      this.default_map.add_reg(this.DIRUCELR1, `UVM_REG_ADDR_WIDTH'h10C, "RW", 0);
		this.DIRUCELR1_ErrAddr = this.DIRUCELR1.ErrAddr;
		this.DIRUCELR1_Rsvd1 = this.DIRUCELR1.Rsvd1;
      this.DIRUCESAR = ral_reg_concerto_registers_Directory_Unit_DIRUCESAR::type_id::create("DIRUCESAR",,get_full_name());
      this.DIRUCESAR.configure(this, null, "");
      this.DIRUCESAR.build();
      this.default_map.add_reg(this.DIRUCESAR, `UVM_REG_ADDR_WIDTH'h124, "RW", 0);
		this.DIRUCESAR_ErrVld = this.DIRUCESAR.ErrVld;
		this.DIRUCESAR_ErrOvf = this.DIRUCESAR.ErrOvf;
		this.DIRUCESAR_Rsvd1 = this.DIRUCESAR.Rsvd1;
		this.DIRUCESAR_ErrCount = this.DIRUCESAR.ErrCount;
		this.DIRUCESAR_ErrType = this.DIRUCESAR.ErrType;
		this.DIRUCESAR_ErrInfo = this.DIRUCESAR.ErrInfo;
		this.DIRUCESAR_Rsvd2 = this.DIRUCESAR.Rsvd2;
      this.DIRUUECR = ral_reg_concerto_registers_Directory_Unit_DIRUUECR::type_id::create("DIRUUECR",,get_full_name());
      this.DIRUUECR.configure(this, null, "");
      this.DIRUUECR.build();
      this.default_map.add_reg(this.DIRUUECR, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.DIRUUECR_ErrDetEn = this.DIRUUECR.ErrDetEn;
		this.DIRUUECR_ErrIntEn = this.DIRUUECR.ErrIntEn;
		this.DIRUUECR_Rsvd1 = this.DIRUUECR.Rsvd1;
		this.DIRUUECR_ErrThreshold = this.DIRUUECR.ErrThreshold;
		this.DIRUUECR_Rsvd2 = this.DIRUUECR.Rsvd2;
      this.DIRUUESR = ral_reg_concerto_registers_Directory_Unit_DIRUUESR::type_id::create("DIRUUESR",,get_full_name());
      this.DIRUUESR.configure(this, null, "");
      this.DIRUUESR.build();
      this.default_map.add_reg(this.DIRUUESR, `UVM_REG_ADDR_WIDTH'h144, "RW", 0);
		this.DIRUUESR_ErrVld = this.DIRUUESR.ErrVld;
		this.DIRUUESR_ErrOvf = this.DIRUUESR.ErrOvf;
		this.DIRUUESR_Rsvd1 = this.DIRUUESR.Rsvd1;
		this.DIRUUESR_ErrCount = this.DIRUUESR.ErrCount;
		this.DIRUUESR_ErrType = this.DIRUUESR.ErrType;
		this.DIRUUESR_ErrInfo = this.DIRUUESR.ErrInfo;
		this.DIRUUESR_Rsvd2 = this.DIRUUESR.Rsvd2;
      this.DIRUUELR0 = ral_reg_concerto_registers_Directory_Unit_DIRUUELR0::type_id::create("DIRUUELR0",,get_full_name());
      this.DIRUUELR0.configure(this, null, "");
      this.DIRUUELR0.build();
      this.default_map.add_reg(this.DIRUUELR0, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.DIRUUELR0_ErrEntry = this.DIRUUELR0.ErrEntry;
		this.DIRUUELR0_ErrWay = this.DIRUUELR0.ErrWay;
		this.DIRUUELR0_ErrWord = this.DIRUUELR0.ErrWord;
      this.DIRUUELR1 = ral_reg_concerto_registers_Directory_Unit_DIRUUELR1::type_id::create("DIRUUELR1",,get_full_name());
      this.DIRUUELR1.configure(this, null, "");
      this.DIRUUELR1.build();
      this.default_map.add_reg(this.DIRUUELR1, `UVM_REG_ADDR_WIDTH'h14C, "RW", 0);
		this.DIRUUELR1_ErrAddr = this.DIRUUELR1.ErrAddr;
		this.DIRUUELR1_Rsvd1 = this.DIRUUELR1.Rsvd1;
      this.DIRUUESAR = ral_reg_concerto_registers_Directory_Unit_DIRUUESAR::type_id::create("DIRUUESAR",,get_full_name());
      this.DIRUUESAR.configure(this, null, "");
      this.DIRUUESAR.build();
      this.default_map.add_reg(this.DIRUUESAR, `UVM_REG_ADDR_WIDTH'h164, "RW", 0);
		this.DIRUUESAR_ErrVld = this.DIRUUESAR.ErrVld;
		this.DIRUUESAR_ErrOvf = this.DIRUUESAR.ErrOvf;
		this.DIRUUESAR_Rsvd1 = this.DIRUUESAR.Rsvd1;
		this.DIRUUESAR_ErrCount = this.DIRUUESAR.ErrCount;
		this.DIRUUESAR_ErrType = this.DIRUUESAR.ErrType;
		this.DIRUUESAR_ErrInfo = this.DIRUUESAR.ErrInfo;
		this.DIRUUESAR_Rsvd2 = this.DIRUUESAR.Rsvd2;
      this.DIRUDCR = ral_reg_concerto_registers_Directory_Unit_DIRUDCR::type_id::create("DIRUDCR",,get_full_name());
      this.DIRUDCR.configure(this, null, "");
      this.DIRUDCR.build();
      this.default_map.add_reg(this.DIRUDCR, `UVM_REG_ADDR_WIDTH'hF00, "RW", 0);
		this.DIRUDCR_DbgOp = this.DIRUDCR.DbgOp;
		this.DbgOp = this.DIRUDCR.DbgOp;
		this.DIRUDCR_Rsvd1 = this.DIRUDCR.Rsvd1;
      this.DIRUDAR = ral_reg_concerto_registers_Directory_Unit_DIRUDAR::type_id::create("DIRUDAR",,get_full_name());
      this.DIRUDAR.configure(this, null, "");
      this.DIRUDAR.build();
      this.default_map.add_reg(this.DIRUDAR, `UVM_REG_ADDR_WIDTH'hF04, "RO", 0);
		this.DIRUDAR_DbgOpActv = this.DIRUDAR.DbgOpActv;
		this.DbgOpActv = this.DIRUDAR.DbgOpActv;
		this.DIRUDAR_DbgOpFail = this.DIRUDAR.DbgOpFail;
		this.DbgOpFail = this.DIRUDAR.DbgOpFail;
		this.DIRUDAR_Rsvd1 = this.DIRUDAR.Rsvd1;
      this.DIRUDLR = ral_reg_concerto_registers_Directory_Unit_DIRUDLR::type_id::create("DIRUDLR",,get_full_name());
      this.DIRUDLR.configure(this, null, "");
      this.DIRUDLR.build();
      this.default_map.add_reg(this.DIRUDLR, `UVM_REG_ADDR_WIDTH'hF08, "RW", 0);
		this.DIRUDLR_DbgEntry = this.DIRUDLR.DbgEntry;
		this.DbgEntry = this.DIRUDLR.DbgEntry;
		this.DIRUDLR_DbgStruct = this.DIRUDLR.DbgStruct;
		this.DbgStruct = this.DIRUDLR.DbgStruct;
		this.DIRUDLR_DbgWord = this.DIRUDLR.DbgWord;
		this.DbgWord = this.DIRUDLR.DbgWord;
      this.DIRUDDR = ral_reg_concerto_registers_Directory_Unit_DIRUDDR::type_id::create("DIRUDDR",,get_full_name());
      this.DIRUDDR.configure(this, null, "");
      this.DIRUDDR.build();
      this.default_map.add_reg(this.DIRUDDR, `UVM_REG_ADDR_WIDTH'hF10, "RO", 0);
		this.DIRUDDR_DbgData = this.DIRUDDR.DbgData;
		this.DbgData = this.DIRUDDR.DbgData;
      this.DIRUDFR = ral_reg_concerto_registers_Directory_Unit_DIRUDFR::type_id::create("DIRUDFR",,get_full_name());
      this.DIRUDFR.configure(this, null, "");
      this.DIRUDFR.build();
      this.default_map.add_reg(this.DIRUDFR, `UVM_REG_ADDR_WIDTH'hF20, "RW", 0);
		this.DIRUDFR_DIRUDFR = this.DIRUDFR.DIRUDFR;
      this.DIRUIDR = ral_reg_concerto_registers_Directory_Unit_DIRUIDR::type_id::create("DIRUIDR",,get_full_name());
      this.DIRUIDR.configure(this, null, "");
      this.DIRUIDR.build();
      this.default_map.add_reg(this.DIRUIDR, `UVM_REG_ADDR_WIDTH'hFFC, "RO", 0);
		this.DIRUIDR_ImplVer = this.DIRUIDR.ImplVer;
		this.ImplVer = this.DIRUIDR.ImplVer;
		this.DIRUIDR_Rsvd1 = this.DIRUIDR.Rsvd1;
   endfunction : build

	`uvm_object_utils(ral_block_concerto_registers_Directory_Unit)

endclass : ral_block_concerto_registers_Directory_Unit



`endif
