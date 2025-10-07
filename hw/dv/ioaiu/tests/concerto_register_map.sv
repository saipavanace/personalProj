`ifndef RAL_NCORE
`define RAL_NCORE

import uvm_pkg::*;

class ral_reg_ncore_ioaiu_UIDR extends uvm_reg;
	uvm_reg_field RPN;
	uvm_reg_field NRRI;
	uvm_reg_field NUnitId;
	uvm_reg_field Rsvd1;
	uvm_reg_field Valid;

	function new(string name = "ncore_ioaiu_UIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.RPN = uvm_reg_field::type_id::create("RPN",,get_full_name());
      this.RPN.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
      this.NRRI = uvm_reg_field::type_id::create("NRRI",,get_full_name());
      this.NRRI.configure(this, 4, 8, "RO", 0, 4'h0, 1, 0, 0);
      this.NUnitId = uvm_reg_field::type_id::create("NUnitId",,get_full_name());
      this.NUnitId.configure(this, 3, 12, "RO", 0, 3'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 16, 15, "RO", 0, 16'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RO", 0, 1'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UIDR)

endclass : ral_reg_ncore_ioaiu_UIDR


class ral_reg_ncore_ioaiu_UFUIDR extends uvm_reg;
	uvm_reg_field FUnitId;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_UFUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.FUnitId = uvm_reg_field::type_id::create("FUnitId",,get_full_name());
      this.FUnitId.configure(this, 7, 0, "RO", 0, 7'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 25, 7, "RO", 0, 25'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UFUIDR)

endclass : ral_reg_ncore_ioaiu_UFUIDR


class ral_reg_ncore_ioaiu_CREDIT extends uvm_reg;
	rand uvm_reg_field MRC;
	rand uvm_reg_field MRU;
	rand uvm_reg_field MRR;
	rand uvm_reg_field MRW;

	function new(string name = "ncore_ioaiu_CREDIT");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MRC = uvm_reg_field::type_id::create("MRC",,get_full_name());
      this.MRC.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.MRU = uvm_reg_field::type_id::create("MRU",,get_full_name());
      this.MRU.configure(this, 8, 8, "RW", 0, 8'h0, 1, 0, 1);
      this.MRR = uvm_reg_field::type_id::create("MRR",,get_full_name());
      this.MRR.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.MRW = uvm_reg_field::type_id::create("MRW",,get_full_name());
      this.MRW.configure(this, 8, 24, "RW", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_CREDIT)

endclass : ral_reg_ncore_ioaiu_CREDIT


class ral_reg_ncore_ioaiu_CONTROL extends uvm_reg;
	rand uvm_reg_field cfg;

	function new(string name = "ncore_ioaiu_CONTROL");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.cfg = uvm_reg_field::type_id::create("cfg",,get_full_name());
      this.cfg.configure(this, 32, 0, "RW", 0, 32'h8, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_CONTROL)

endclass : ral_reg_ncore_ioaiu_CONTROL


class ral_reg_ncore_ioaiu_POOL extends uvm_reg;
	rand uvm_reg_field WR;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field RD;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_ioaiu_POOL");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.WR = uvm_reg_field::type_id::create("WR",,get_full_name());
      this.WR.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.RD = uvm_reg_field::type_id::create("RD",,get_full_name());
      this.RD.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_POOL)

endclass : ral_reg_ncore_ioaiu_POOL


class ral_reg_ncore_ioaiu_LIMIT0 extends uvm_reg;
	rand uvm_reg_field OTT;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field STT;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_ioaiu_LIMIT0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.OTT = uvm_reg_field::type_id::create("OTT",,get_full_name());
      this.OTT.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.STT = uvm_reg_field::type_id::create("STT",,get_full_name());
      this.STT.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_LIMIT0)

endclass : ral_reg_ncore_ioaiu_LIMIT0


class ral_reg_ncore_ioaiu_LIMIT1 extends uvm_reg;
	rand uvm_reg_field WR;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field RD;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_ioaiu_LIMIT1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.WR = uvm_reg_field::type_id::create("WR",,get_full_name());
      this.WR.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 8, 8, "RO", 0, 8'h0, 1, 0, 1);
      this.RD = uvm_reg_field::type_id::create("RD",,get_full_name());
      this.RD.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_LIMIT1)

endclass : ral_reg_ncore_ioaiu_LIMIT1


class ral_reg_ncore_ioaiu_LIMIT2 extends uvm_reg;
	rand uvm_reg_field EV;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_LIMIT2");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.EV = uvm_reg_field::type_id::create("EV",,get_full_name());
      this.EV.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_LIMIT2)

endclass : ral_reg_ncore_ioaiu_LIMIT2


class ral_reg_ncore_ioaiu_USMCMCR0 extends uvm_reg;
	rand uvm_reg_field MntOp;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ArrayID;
	rand uvm_reg_field SecAttr;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_ioaiu_USMCMCR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntOp = uvm_reg_field::type_id::create("MntOp",,get_full_name());
      this.MntOp.configure(this, 4, 0, "RW", 0, 4'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 12, 4, "RO", 0, 12'h0, 1, 0, 0);
      this.ArrayID = uvm_reg_field::type_id::create("ArrayID",,get_full_name());
      this.ArrayID.configure(this, 6, 16, "RW", 0, 6'h0, 1, 0, 0);
      this.SecAttr = uvm_reg_field::type_id::create("SecAttr",,get_full_name());
      this.SecAttr.configure(this, 1, 22, "RW", 0, 1'h0, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 9, 23, "RO", 0, 9'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_USMCMCR0)

endclass : ral_reg_ncore_ioaiu_USMCMCR0


class ral_reg_ncore_ioaiu_USMCMAR0 extends uvm_reg;
	uvm_reg_field MntOpActv;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_USMCMAR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntOpActv = uvm_reg_field::type_id::create("MntOpActv",,get_full_name());
      this.MntOpActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 31, 1, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_USMCMAR0)

endclass : ral_reg_ncore_ioaiu_USMCMAR0


class ral_reg_ncore_ioaiu_USMCMLR00 extends uvm_reg;
	rand uvm_reg_field MntSet;
	rand uvm_reg_field MntWay;
	rand uvm_reg_field MntWord;

	function new(string name = "ncore_ioaiu_USMCMLR00");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_USMCMLR00)

endclass : ral_reg_ncore_ioaiu_USMCMLR00


class ral_reg_ncore_ioaiu_USMCMLR10 extends uvm_reg;
	rand uvm_reg_field MntAddr;
	rand uvm_reg_field MntRange;

	function new(string name = "ncore_ioaiu_USMCMLR10");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntAddr = uvm_reg_field::type_id::create("MntAddr",,get_full_name());
      this.MntAddr.configure(this, 16, 0, "RW", 0, 16'h0, 1, 0, 1);
      this.MntRange = uvm_reg_field::type_id::create("MntRange",,get_full_name());
      this.MntRange.configure(this, 16, 16, "RW", 0, 16'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_USMCMLR10)

endclass : ral_reg_ncore_ioaiu_USMCMLR10


class ral_reg_ncore_ioaiu_USMCMDR0 extends uvm_reg;
	uvm_reg_field MntData;

	function new(string name = "ncore_ioaiu_USMCMDR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntData = uvm_reg_field::type_id::create("MntData",,get_full_name());
      this.MntData.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_USMCMDR0)

endclass : ral_reg_ncore_ioaiu_USMCMDR0


class ral_reg_ncore_ioaiu_UCECR extends uvm_reg;
	rand uvm_reg_field ErrDetEn;
	rand uvm_reg_field ErrIntEn;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrThreshold;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_ioaiu_UCECR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_UCECR)

endclass : ral_reg_ncore_ioaiu_UCECR


class ral_reg_ncore_ioaiu_UCESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	uvm_reg_field ErrInfo;

	function new(string name = "ncore_ioaiu_UCESR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_UCESR)

endclass : ral_reg_ncore_ioaiu_UCESR


class ral_reg_ncore_ioaiu_UCELR0 extends uvm_reg;
	rand uvm_reg_field ErrAddr;

	function new(string name = "ncore_ioaiu_UCELR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UCELR0)

endclass : ral_reg_ncore_ioaiu_UCELR0


class ral_reg_ncore_ioaiu_UCELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_UCELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UCELR1)

endclass : ral_reg_ncore_ioaiu_UCELR1


class ral_reg_ncore_ioaiu_UCESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field ErrInfo;

	function new(string name = "ncore_ioaiu_UCESAR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_UCESAR)

endclass : ral_reg_ncore_ioaiu_UCESAR


class ral_reg_ncore_ioaiu_UUECR extends uvm_reg;
	rand uvm_reg_field ErrDetEn;

	function new(string name = "ncore_ioaiu_UUECR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrDetEn = uvm_reg_field::type_id::create("ErrDetEn",,get_full_name());
      this.ErrDetEn.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UUECR)

endclass : ral_reg_ncore_ioaiu_UUECR


class ral_reg_ncore_ioaiu_UUESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	uvm_reg_field ErrInfo;

	function new(string name = "ncore_ioaiu_UUESR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_UUESR)

endclass : ral_reg_ncore_ioaiu_UUESR


class ral_reg_ncore_ioaiu_UUELR0 extends uvm_reg;
	rand uvm_reg_field ErrAddr;

	function new(string name = "ncore_ioaiu_UUELR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UUELR0)

endclass : ral_reg_ncore_ioaiu_UUELR0


class ral_reg_ncore_ioaiu_UUELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_UUELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UUELR1)

endclass : ral_reg_ncore_ioaiu_UUELR1


class ral_reg_ncore_ioaiu_UUESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field ErrType;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field ErrInfo;

	function new(string name = "ncore_ioaiu_UUESAR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_UUESAR)

endclass : ral_reg_ncore_ioaiu_UUESAR


class ral_reg_ncore_ioaiu_GP0RA extends uvm_reg;
//	rand uvm_reg_field DIGId;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field HUI;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field Size;
	uvm_reg_field Rsvd3;
	rand uvm_reg_field HUT;
	rand uvm_reg_field Valid;

	function new(string name = "ncore_ioaiu_GP0RA");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_GP0RA)

endclass : ral_reg_ncore_ioaiu_GP0RA


class ral_reg_ncore_ioaiu_GP0RBLR extends uvm_reg;
	rand uvm_reg_field Address;

	function new(string name = "ncore_ioaiu_GP0RBLR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Address = uvm_reg_field::type_id::create("Address",,get_full_name());
      this.Address.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_GP0RBLR)

endclass : ral_reg_ncore_ioaiu_GP0RBLR


class ral_reg_ncore_ioaiu_GP0RBHR extends uvm_reg;
	rand uvm_reg_field Address;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_GP0RBHR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Address = uvm_reg_field::type_id::create("Address",,get_full_name());
      this.Address.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_GP0RBHR)

endclass : ral_reg_ncore_ioaiu_GP0RBHR


class ral_reg_ncore_ioaiu_BRAR extends uvm_reg;
//	rand uvm_reg_field DIGId;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field HUI;
	rand uvm_reg_field HUT;
	uvm_reg_field Rsvd2;
	rand uvm_reg_field Size;
	uvm_reg_field Rsvd3;
	rand uvm_reg_field ST;
	rand uvm_reg_field Valid;

	function new(string name = "ncore_ioaiu_BRAR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_BRAR)

endclass : ral_reg_ncore_ioaiu_BRAR


class ral_reg_ncore_ioaiu_BRBLR extends uvm_reg;
	rand uvm_reg_field Address;

	function new(string name = "ncore_ioaiu_BRBLR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Address = uvm_reg_field::type_id::create("Address",,get_full_name());
      this.Address.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_BRBLR)

endclass : ral_reg_ncore_ioaiu_BRBLR


class ral_reg_ncore_ioaiu_BRBHR extends uvm_reg;
	rand uvm_reg_field Address;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_BRBHR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.Address = uvm_reg_field::type_id::create("Address",,get_full_name());
      this.Address.configure(this, 8, 0, "RW", 0, 8'h0, 1, 0, 1);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 24, 8, "RO", 0, 24'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_BRBHR)

endclass : ral_reg_ncore_ioaiu_BRBHR


class ral_reg_ncore_ioaiu_NRSBAR extends uvm_reg;
	rand uvm_reg_field NRSBA;

	function new(string name = "ncore_ioaiu_NRSBAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.NRSBA = uvm_reg_field::type_id::create("NRSBA",,get_full_name());
      this.NRSBA.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_NRSBAR)

endclass : ral_reg_ncore_ioaiu_NRSBAR


class ral_reg_ncore_ioaiu_AMIGR extends uvm_reg;
	rand uvm_reg_field Valid;
	rand uvm_reg_field AMIGS;
	uvm_reg_field Rsvd1;

	function new(string name = "ncore_ioaiu_AMIGR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_AMIGR)

endclass : ral_reg_ncore_ioaiu_AMIGR


class ral_reg_ncore_ioaiu_MAIFR extends uvm_reg;
	uvm_reg_field Rsvd1;
	rand uvm_reg_field MIG2AIFId;
	rand uvm_reg_field MIG3AIFId;
	rand uvm_reg_field MIG4AIFId;
	uvm_reg_field Rsvd2;

	function new(string name = "ncore_ioaiu_MAIFR");
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

	`uvm_object_utils(ral_reg_ncore_ioaiu_MAIFR)

endclass : ral_reg_ncore_ioaiu_MAIFR


class ral_reg_ncore_ioaiu_UENGIDR extends uvm_reg;
	uvm_reg_field EngVerId;

	function new(string name = "ncore_ioaiu_UENGIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.EngVerId = uvm_reg_field::type_id::create("EngVerId",,get_full_name());
      this.EngVerId.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UENGIDR)

endclass : ral_reg_ncore_ioaiu_UENGIDR


class ral_reg_ncore_ioaiu_UINFOR extends uvm_reg;
	uvm_reg_field ImplVer;
	uvm_reg_field UT;
	uvm_reg_field Rsvd1;
	uvm_reg_field Valid;

	function new(string name = "ncore_ioaiu_UINFOR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ImplVer = uvm_reg_field::type_id::create("ImplVer",,get_full_name());
      this.ImplVer.configure(this, 8, 0, "RO", 0, 8'h0, 1, 0, 1);
      this.UT = uvm_reg_field::type_id::create("UT",,get_full_name());
      this.UT.configure(this, 4, 8, "RO", 0, 4'ha, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 19, 12, "RO", 0, 19'h0, 1, 0, 0);
      this.Valid = uvm_reg_field::type_id::create("Valid",,get_full_name());
      this.Valid.configure(this, 1, 31, "RO", 0, 1'h1, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ncore_ioaiu_UINFOR)

endclass : ral_reg_ncore_ioaiu_UINFOR


class ral_block_ncore_ioaiu extends uvm_reg_block;
	rand ral_reg_ncore_ioaiu_UIDR UIDR;
	rand ral_reg_ncore_ioaiu_UFUIDR UFUIDR;
	rand ral_reg_ncore_ioaiu_CREDIT EDR0;
	rand ral_reg_ncore_ioaiu_CONTROL EDR1;
	rand ral_reg_ncore_ioaiu_POOL EDR2;
	rand ral_reg_ncore_ioaiu_LIMIT0 EDR3;
	rand ral_reg_ncore_ioaiu_LIMIT1 EDR4;
	rand ral_reg_ncore_ioaiu_LIMIT2 EDR5;
	rand ral_reg_ncore_ioaiu_USMCMCR0 PCMCR;
	rand ral_reg_ncore_ioaiu_USMCMAR0 PCMAR;
	rand ral_reg_ncore_ioaiu_USMCMLR00 PCMLR0;
	rand ral_reg_ncore_ioaiu_USMCMLR10 PCMLR1;
	rand ral_reg_ncore_ioaiu_USMCMDR0 PCMDR;
	rand ral_reg_ncore_ioaiu_UCECR UCECR;
	rand ral_reg_ncore_ioaiu_UCESR UCESR;
	rand ral_reg_ncore_ioaiu_UCELR0 UCELR0;
	rand ral_reg_ncore_ioaiu_UCELR1 UCELR1;
	rand ral_reg_ncore_ioaiu_UCESAR UCESAR;
	rand ral_reg_ncore_ioaiu_UUECR UUECR;
	rand ral_reg_ncore_ioaiu_UUESR UUESR;
	rand ral_reg_ncore_ioaiu_UUELR0 UUELR0;
	rand ral_reg_ncore_ioaiu_UUELR1 UUELR1;
	rand ral_reg_ncore_ioaiu_UUESAR UUESAR;
	rand ral_reg_ncore_ioaiu_GP0RA GP0RA;
	rand ral_reg_ncore_ioaiu_GP0RBLR GP0RBLR;
	rand ral_reg_ncore_ioaiu_GP0RBHR GP0RBHR;
	rand ral_reg_ncore_ioaiu_BRAR BRAR;
	rand ral_reg_ncore_ioaiu_BRBLR BRBLR;
	rand ral_reg_ncore_ioaiu_BRBHR BRBHR;
	rand ral_reg_ncore_ioaiu_NRSBAR NRSBAR;
	rand ral_reg_ncore_ioaiu_AMIGR AMIGR;
	rand ral_reg_ncore_ioaiu_MAIFR MIFSR;
	rand ral_reg_ncore_ioaiu_UENGIDR UENGIDR;
	rand ral_reg_ncore_ioaiu_UINFOR UINFOR;
	uvm_reg_field UIDR_RPN;
	uvm_reg_field RPN;
	uvm_reg_field UIDR_NRRI;
	uvm_reg_field NRRI;
	uvm_reg_field UIDR_NUnitId;
	uvm_reg_field NUnitId;
	uvm_reg_field UIDR_Rsvd1;
	uvm_reg_field UIDR_Valid;
	uvm_reg_field UFUIDR_FUnitId;
	uvm_reg_field FUnitId;
	uvm_reg_field UFUIDR_Rsvd1;
	rand uvm_reg_field CREDIT_MRC;
	rand uvm_reg_field MRC;
	rand uvm_reg_field CREDIT_MRU;
	rand uvm_reg_field MRU;
	rand uvm_reg_field CREDIT_MRR;
	rand uvm_reg_field MRR;
	rand uvm_reg_field CREDIT_MRW;
	rand uvm_reg_field MRW;
	rand uvm_reg_field CONTROL_cfg;
	rand uvm_reg_field cfg;
	rand uvm_reg_field POOL_WR;
	uvm_reg_field POOL_Rsvd1;
	rand uvm_reg_field POOL_RD;
	uvm_reg_field POOL_Rsvd2;
	rand uvm_reg_field LIMIT0_OTT;
	rand uvm_reg_field OTT;
	uvm_reg_field LIMIT0_Rsvd1;
	rand uvm_reg_field LIMIT0_STT;
	rand uvm_reg_field STT;
	uvm_reg_field LIMIT0_Rsvd2;
	rand uvm_reg_field LIMIT1_WR;
	uvm_reg_field LIMIT1_Rsvd1;
	rand uvm_reg_field LIMIT1_RD;
	uvm_reg_field LIMIT1_Rsvd2;
	rand uvm_reg_field LIMIT2_EV;
	rand uvm_reg_field EV;
	uvm_reg_field LIMIT2_Rsvd1;
	rand uvm_reg_field USMCMCR0_MntOp;
	rand uvm_reg_field MntOp;
	uvm_reg_field USMCMCR0_Rsvd1;
	rand uvm_reg_field USMCMCR0_ArrayID;
	rand uvm_reg_field ArrayID;
	rand uvm_reg_field USMCMCR0_SecAttr;
	rand uvm_reg_field SecAttr;
	uvm_reg_field USMCMCR0_Rsvd2;
	uvm_reg_field USMCMAR0_MntOpActv;
	uvm_reg_field MntOpActv;
	uvm_reg_field USMCMAR0_Rsvd1;
	rand uvm_reg_field USMCMLR00_MntSet;
	rand uvm_reg_field MntSet;
	rand uvm_reg_field USMCMLR00_MntWay;
	rand uvm_reg_field MntWay;
	rand uvm_reg_field USMCMLR00_MntWord;
	rand uvm_reg_field MntWord;
	rand uvm_reg_field USMCMLR10_MntAddr;
	rand uvm_reg_field MntAddr;
	rand uvm_reg_field USMCMLR10_MntRange;
	rand uvm_reg_field MntRange;
	uvm_reg_field USMCMDR0_MntData;
	uvm_reg_field MntData;
	rand uvm_reg_field UCECR_ErrDetEn;
	rand uvm_reg_field UCECR_ErrIntEn;
	rand uvm_reg_field ErrIntEn;
	uvm_reg_field UCECR_Rsvd1;
	rand uvm_reg_field UCECR_ErrThreshold;
	rand uvm_reg_field ErrThreshold;
	uvm_reg_field UCECR_Rsvd2;
	rand uvm_reg_field UCESR_ErrVld;
	uvm_reg_field UCESR_Rsvd1;
	uvm_reg_field UCESR_ErrType;
	uvm_reg_field UCESR_Rsvd2;
	uvm_reg_field UCESR_ErrInfo;
	rand uvm_reg_field UCELR0_ErrAddr;
	rand uvm_reg_field UCELR1_ErrAddr;
	uvm_reg_field UCELR1_Rsvd1;
	rand uvm_reg_field UCESAR_ErrVld;
	uvm_reg_field UCESAR_Rsvd1;
	rand uvm_reg_field UCESAR_ErrType;
	uvm_reg_field UCESAR_Rsvd2;
	rand uvm_reg_field UCESAR_ErrInfo;
	rand uvm_reg_field UUECR_ErrDetEn;
	rand uvm_reg_field UUESR_ErrVld;
	uvm_reg_field UUESR_Rsvd1;
	uvm_reg_field UUESR_ErrType;
	uvm_reg_field UUESR_Rsvd2;
	uvm_reg_field UUESR_ErrInfo;
	rand uvm_reg_field UUELR0_ErrAddr;
	rand uvm_reg_field UUELR1_ErrAddr;
	uvm_reg_field UUELR1_Rsvd1;
	rand uvm_reg_field UUESAR_ErrVld;
	uvm_reg_field UUESAR_Rsvd1;
	rand uvm_reg_field UUESAR_ErrType;
	uvm_reg_field UUESAR_Rsvd2;
	rand uvm_reg_field UUESAR_ErrInfo;
//	rand uvm_reg_field GP0RA_DIGId;
	uvm_reg_field GP0RA_Rsvd1;
	rand uvm_reg_field GP0RA_HUI;
	uvm_reg_field GP0RA_Rsvd2;
	rand uvm_reg_field GP0RA_Size;
	uvm_reg_field GP0RA_Rsvd3;
	rand uvm_reg_field GP0RA_HUT;
	rand uvm_reg_field GP0RA_Valid;
	rand uvm_reg_field GP0RBLR_Address;
	rand uvm_reg_field GP0RBHR_Address;
	uvm_reg_field GP0RBHR_Rsvd1;
//	rand uvm_reg_field BRAR_DIGId;
	uvm_reg_field BRAR_Rsvd1;
	rand uvm_reg_field BRAR_HUI;
	rand uvm_reg_field BRAR_HUT;
	uvm_reg_field BRAR_Rsvd2;
	rand uvm_reg_field BRAR_Size;
	uvm_reg_field BRAR_Rsvd3;
	rand uvm_reg_field BRAR_ST;
	rand uvm_reg_field ST;
	rand uvm_reg_field BRAR_Valid;
	rand uvm_reg_field BRBLR_Address;
	rand uvm_reg_field BRBHR_Address;
	uvm_reg_field BRBHR_Rsvd1;
	rand uvm_reg_field NRSBAR_NRSBA;
	rand uvm_reg_field NRSBA;
	rand uvm_reg_field AMIGR_Valid;
	rand uvm_reg_field AMIGR_AMIGS;
	rand uvm_reg_field AMIGS;
	uvm_reg_field AMIGR_Rsvd1;
	uvm_reg_field MAIFR_Rsvd1;
	rand uvm_reg_field MAIFR_MIG2AIFId;
	rand uvm_reg_field MIG2AIFId;
	rand uvm_reg_field MAIFR_MIG3AIFId;
	rand uvm_reg_field MIG3AIFId;
	rand uvm_reg_field MAIFR_MIG4AIFId;
	rand uvm_reg_field MIG4AIFId;
	uvm_reg_field MAIFR_Rsvd2;
	uvm_reg_field UENGIDR_EngVerId;
	uvm_reg_field EngVerId;
	uvm_reg_field UINFOR_ImplVer;
	uvm_reg_field ImplVer;
	uvm_reg_field UINFOR_UT;
	uvm_reg_field UT;
	uvm_reg_field UINFOR_Rsvd1;
	uvm_reg_field UINFOR_Valid;

	function new(string name = "ncore_ioaiu");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.UIDR = ral_reg_ncore_ioaiu_UIDR::type_id::create("UIDR",,get_full_name());
      this.UIDR.configure(this, null, "");
      this.UIDR.build();
      this.default_map.add_reg(this.UIDR, `UVM_REG_ADDR_WIDTH'h0, "RO", 0);
		this.UIDR_RPN = this.UIDR.RPN;
		this.RPN = this.UIDR.RPN;
		this.UIDR_NRRI = this.UIDR.NRRI;
		this.NRRI = this.UIDR.NRRI;
		this.UIDR_NUnitId = this.UIDR.NUnitId;
		this.NUnitId = this.UIDR.NUnitId;
		this.UIDR_Rsvd1 = this.UIDR.Rsvd1;
		this.UIDR_Valid = this.UIDR.Valid;
      this.UFUIDR = ral_reg_ncore_ioaiu_UFUIDR::type_id::create("UFUIDR",,get_full_name());
      this.UFUIDR.configure(this, null, "");
      this.UFUIDR.build();
      this.default_map.add_reg(this.UFUIDR, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);
		this.UFUIDR_FUnitId = this.UFUIDR.FUnitId;
		this.FUnitId = this.UFUIDR.FUnitId;
		this.UFUIDR_Rsvd1 = this.UFUIDR.Rsvd1;
      this.CREDIT = ral_reg_ncore_ioaiu_CREDIT::type_id::create("CREDIT",,get_full_name());
      this.CREDIT.configure(this, null, "");
      this.CREDIT.build();
      this.default_map.add_reg(this.CREDIT, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
		this.CREDIT_MRC = this.CREDIT.MRC;
		this.MRC = this.CREDIT.MRC;
		this.CREDIT_MRU = this.CREDIT.MRU;
		this.MRU = this.CREDIT.MRU;
		this.CREDIT_MRR = this.CREDIT.MRR;
		this.MRR = this.CREDIT.MRR;
		this.CREDIT_MRW = this.CREDIT.MRW;
		this.MRW = this.CREDIT.MRW;
      this.CONTROL = ral_reg_ncore_ioaiu_CONTROL::type_id::create("CONTROL",,get_full_name());
      this.CONTROL.configure(this, null, "");
      this.CONTROL.build();
      this.default_map.add_reg(this.CONTROL, `UVM_REG_ADDR_WIDTH'h44, "RW", 0);
		this.CONTROL_cfg = this.CONTROL.cfg;
		this.cfg = this.CONTROL.cfg;
      this.POOL = ral_reg_ncore_ioaiu_POOL::type_id::create("POOL",,get_full_name());
      this.POOL.configure(this, null, "");
      this.POOL.build();
      this.default_map.add_reg(this.POOL, `UVM_REG_ADDR_WIDTH'h48, "RW", 0);
		this.POOL_WR = this.POOL.WR;
		this.POOL_Rsvd1 = this.POOL.Rsvd1;
		this.POOL_RD = this.POOL.RD;
		this.POOL_Rsvd2 = this.POOL.Rsvd2;
      this.LIMIT0 = ral_reg_ncore_ioaiu_LIMIT0::type_id::create("LIMIT0",,get_full_name());
      this.LIMIT0.configure(this, null, "");
      this.LIMIT0.build();
      this.default_map.add_reg(this.LIMIT0, `UVM_REG_ADDR_WIDTH'h4C, "RW", 0);
		this.LIMIT0_OTT = this.LIMIT0.OTT;
		this.OTT = this.LIMIT0.OTT;
		this.LIMIT0_Rsvd1 = this.LIMIT0.Rsvd1;
		this.LIMIT0_STT = this.LIMIT0.STT;
		this.STT = this.LIMIT0.STT;
		this.LIMIT0_Rsvd2 = this.LIMIT0.Rsvd2;
      this.LIMIT1 = ral_reg_ncore_ioaiu_LIMIT1::type_id::create("LIMIT1",,get_full_name());
      this.LIMIT1.configure(this, null, "");
      this.LIMIT1.build();
      this.default_map.add_reg(this.LIMIT1, `UVM_REG_ADDR_WIDTH'h50, "RW", 0);
		this.LIMIT1_WR = this.LIMIT1.WR;
		this.LIMIT1_Rsvd1 = this.LIMIT1.Rsvd1;
		this.LIMIT1_RD = this.LIMIT1.RD;
		this.LIMIT1_Rsvd2 = this.LIMIT1.Rsvd2;
      this.LIMIT2 = ral_reg_ncore_ioaiu_LIMIT2::type_id::create("LIMIT2",,get_full_name());
      this.LIMIT2.configure(this, null, "");
      this.LIMIT2.build();
      this.default_map.add_reg(this.LIMIT2, `UVM_REG_ADDR_WIDTH'h54, "RW", 0);
		this.LIMIT2_EV = this.LIMIT2.EV;
		this.EV = this.LIMIT2.EV;
		this.LIMIT2_Rsvd1 = this.LIMIT2.Rsvd1;
      this.USMCMCR0 = ral_reg_ncore_ioaiu_USMCMCR0::type_id::create("USMCMCR0",,get_full_name());
      this.USMCMCR0.configure(this, null, "");
      this.USMCMCR0.build();
      this.default_map.add_reg(this.USMCMCR0, `UVM_REG_ADDR_WIDTH'h58, "RW", 0);
		this.USMCMCR0_MntOp = this.USMCMCR0.MntOp;
		this.MntOp = this.USMCMCR0.MntOp;
		this.USMCMCR0_Rsvd1 = this.USMCMCR0.Rsvd1;
		this.USMCMCR0_ArrayID = this.USMCMCR0.ArrayID;
		this.ArrayID = this.USMCMCR0.ArrayID;
		this.USMCMCR0_SecAttr = this.USMCMCR0.SecAttr;
		this.SecAttr = this.USMCMCR0.SecAttr;
		this.USMCMCR0_Rsvd2 = this.USMCMCR0.Rsvd2;
      this.USMCMAR0 = ral_reg_ncore_ioaiu_USMCMAR0::type_id::create("USMCMAR0",,get_full_name());
      this.USMCMAR0.configure(this, null, "");
      this.USMCMAR0.build();
      this.default_map.add_reg(this.USMCMAR0, `UVM_REG_ADDR_WIDTH'h5C, "RO", 0);
		this.USMCMAR0_MntOpActv = this.USMCMAR0.MntOpActv;
		this.MntOpActv = this.USMCMAR0.MntOpActv;
		this.USMCMAR0_Rsvd1 = this.USMCMAR0.Rsvd1;
      this.USMCMLR00 = ral_reg_ncore_ioaiu_USMCMLR00::type_id::create("USMCMLR00",,get_full_name());
      this.USMCMLR00.configure(this, null, "");
      this.USMCMLR00.build();
      this.default_map.add_reg(this.USMCMLR00, `UVM_REG_ADDR_WIDTH'h60, "RW", 0);
		this.USMCMLR00_MntSet = this.USMCMLR00.MntSet;
		this.MntSet = this.USMCMLR00.MntSet;
		this.USMCMLR00_MntWay = this.USMCMLR00.MntWay;
		this.MntWay = this.USMCMLR00.MntWay;
		this.USMCMLR00_MntWord = this.USMCMLR00.MntWord;
		this.MntWord = this.USMCMLR00.MntWord;
      this.USMCMLR10 = ral_reg_ncore_ioaiu_USMCMLR10::type_id::create("USMCMLR10",,get_full_name());
      this.USMCMLR10.configure(this, null, "");
      this.USMCMLR10.build();
      this.default_map.add_reg(this.USMCMLR10, `UVM_REG_ADDR_WIDTH'h64, "RW", 0);
		this.USMCMLR10_MntAddr = this.USMCMLR10.MntAddr;
		this.MntAddr = this.USMCMLR10.MntAddr;
		this.USMCMLR10_MntRange = this.USMCMLR10.MntRange;
		this.MntRange = this.USMCMLR10.MntRange;
      this.USMCMDR0 = ral_reg_ncore_ioaiu_USMCMDR0::type_id::create("USMCMDR0",,get_full_name());
      this.USMCMDR0.configure(this, null, "");
      this.USMCMDR0.build();
      this.default_map.add_reg(this.USMCMDR0, `UVM_REG_ADDR_WIDTH'h68, "RO", 0);
		this.USMCMDR0_MntData = this.USMCMDR0.MntData;
		this.MntData = this.USMCMDR0.MntData;
      this.UCECR = ral_reg_ncore_ioaiu_UCECR::type_id::create("UCECR",,get_full_name());
      this.UCECR.configure(this, null, "");
      this.UCECR.build();
      this.default_map.add_reg(this.UCECR, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.UCECR_ErrDetEn = this.UCECR.ErrDetEn;
		this.UCECR_ErrIntEn = this.UCECR.ErrIntEn;
		this.ErrIntEn = this.UCECR.ErrIntEn;
		this.UCECR_Rsvd1 = this.UCECR.Rsvd1;
		this.UCECR_ErrThreshold = this.UCECR.ErrThreshold;
		this.ErrThreshold = this.UCECR.ErrThreshold;
		this.UCECR_Rsvd2 = this.UCECR.Rsvd2;
      this.UCESR = ral_reg_ncore_ioaiu_UCESR::type_id::create("UCESR",,get_full_name());
      this.UCESR.configure(this, null, "");
      this.UCESR.build();
      this.default_map.add_reg(this.UCESR, `UVM_REG_ADDR_WIDTH'h104, "RW", 0);
		this.UCESR_ErrVld = this.UCESR.ErrVld;
		this.UCESR_Rsvd1 = this.UCESR.Rsvd1;
		this.UCESR_ErrType = this.UCESR.ErrType;
		this.UCESR_Rsvd2 = this.UCESR.Rsvd2;
		this.UCESR_ErrInfo = this.UCESR.ErrInfo;
      this.UCELR0 = ral_reg_ncore_ioaiu_UCELR0::type_id::create("UCELR0",,get_full_name());
      this.UCELR0.configure(this, null, "");
      this.UCELR0.build();
      this.default_map.add_reg(this.UCELR0, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.UCELR0_ErrAddr = this.UCELR0.ErrAddr;
      this.UCELR1 = ral_reg_ncore_ioaiu_UCELR1::type_id::create("UCELR1",,get_full_name());
      this.UCELR1.configure(this, null, "");
      this.UCELR1.build();
      this.default_map.add_reg(this.UCELR1, `UVM_REG_ADDR_WIDTH'h10C, "RW", 0);
		this.UCELR1_ErrAddr = this.UCELR1.ErrAddr;
		this.UCELR1_Rsvd1 = this.UCELR1.Rsvd1;
      this.UCESAR = ral_reg_ncore_ioaiu_UCESAR::type_id::create("UCESAR",,get_full_name());
      this.UCESAR.configure(this, null, "");
      this.UCESAR.build();
      this.default_map.add_reg(this.UCESAR, `UVM_REG_ADDR_WIDTH'h124, "RW", 0);
		this.UCESAR_ErrVld = this.UCESAR.ErrVld;
		this.UCESAR_Rsvd1 = this.UCESAR.Rsvd1;
		this.UCESAR_ErrType = this.UCESAR.ErrType;
		this.UCESAR_Rsvd2 = this.UCESAR.Rsvd2;
		this.UCESAR_ErrInfo = this.UCESAR.ErrInfo;
      this.UUECR = ral_reg_ncore_ioaiu_UUECR::type_id::create("UUECR",,get_full_name());
      this.UUECR.configure(this, null, "");
      this.UUECR.build();
      this.default_map.add_reg(this.UUECR, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.UUECR_ErrDetEn = this.UUECR.ErrDetEn;
      this.UUESR = ral_reg_ncore_ioaiu_UUESR::type_id::create("UUESR",,get_full_name());
      this.UUESR.configure(this, null, "");
      this.UUESR.build();
      this.default_map.add_reg(this.UUESR, `UVM_REG_ADDR_WIDTH'h144, "RW", 0);
		this.UUESR_ErrVld = this.UUESR.ErrVld;
		this.UUESR_Rsvd1 = this.UUESR.Rsvd1;
		this.UUESR_ErrType = this.UUESR.ErrType;
		this.UUESR_Rsvd2 = this.UUESR.Rsvd2;
		this.UUESR_ErrInfo = this.UUESR.ErrInfo;
      this.UUELR0 = ral_reg_ncore_ioaiu_UUELR0::type_id::create("UUELR0",,get_full_name());
      this.UUELR0.configure(this, null, "");
      this.UUELR0.build();
      this.default_map.add_reg(this.UUELR0, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.UUELR0_ErrAddr = this.UUELR0.ErrAddr;
      this.UUELR1 = ral_reg_ncore_ioaiu_UUELR1::type_id::create("UUELR1",,get_full_name());
      this.UUELR1.configure(this, null, "");
      this.UUELR1.build();
      this.default_map.add_reg(this.UUELR1, `UVM_REG_ADDR_WIDTH'h14C, "RW", 0);
		this.UUELR1_ErrAddr = this.UUELR1.ErrAddr;
		this.UUELR1_Rsvd1 = this.UUELR1.Rsvd1;
      this.UUESAR = ral_reg_ncore_ioaiu_UUESAR::type_id::create("UUESAR",,get_full_name());
      this.UUESAR.configure(this, null, "");
      this.UUESAR.build();
      this.default_map.add_reg(this.UUESAR, `UVM_REG_ADDR_WIDTH'h164, "RW", 0);
		this.UUESAR_ErrVld = this.UUESAR.ErrVld;
		this.UUESAR_Rsvd1 = this.UUESAR.Rsvd1;
		this.UUESAR_ErrType = this.UUESAR.ErrType;
		this.UUESAR_Rsvd2 = this.UUESAR.Rsvd2;
		this.UUESAR_ErrInfo = this.UUESAR.ErrInfo;
      this.GP0RA = ral_reg_ncore_ioaiu_GP0RA::type_id::create("GP0RA",,get_full_name());
      this.GP0RA.configure(this, null, "");
      this.GP0RA.build();
      this.default_map.add_reg(this.GP0RA, `UVM_REG_ADDR_WIDTH'h400, "RW", 0);
//		this.GP0RA_DIGId = this.GP0RA.DIGId;
		this.GP0RA_Rsvd1 = this.GP0RA.Rsvd1;
		this.GP0RA_HUI = this.GP0RA.HUI;
		this.GP0RA_Rsvd2 = this.GP0RA.Rsvd2;
		this.GP0RA_Size = this.GP0RA.Size;
		this.GP0RA_Rsvd3 = this.GP0RA.Rsvd3;
		this.GP0RA_HUT = this.GP0RA.HUT;
		this.GP0RA_Valid = this.GP0RA.Valid;
      this.GP0RBLR = ral_reg_ncore_ioaiu_GP0RBLR::type_id::create("GP0RBLR",,get_full_name());
      this.GP0RBLR.configure(this, null, "");
      this.GP0RBLR.build();
      this.default_map.add_reg(this.GP0RBLR, `UVM_REG_ADDR_WIDTH'h404, "RW", 0);
		this.GP0RBLR_Address = this.GP0RBLR.Address;
      this.GP0RBHR = ral_reg_ncore_ioaiu_GP0RBHR::type_id::create("GP0RBHR",,get_full_name());
      this.GP0RBHR.configure(this, null, "");
      this.GP0RBHR.build();
      this.default_map.add_reg(this.GP0RBHR, `UVM_REG_ADDR_WIDTH'h408, "RW", 0);
		this.GP0RBHR_Address = this.GP0RBHR.Address;
		this.GP0RBHR_Rsvd1 = this.GP0RBHR.Rsvd1;
      this.BRAR = ral_reg_ncore_ioaiu_BRAR::type_id::create("BRAR",,get_full_name());
      this.BRAR.configure(this, null, "");
      this.BRAR.build();
      this.default_map.add_reg(this.BRAR, `UVM_REG_ADDR_WIDTH'h800, "RW", 0);
//		this.BRAR_DIGId = this.BRAR.DIGId;
		this.BRAR_Rsvd1 = this.BRAR.Rsvd1;
		this.BRAR_HUI = this.BRAR.HUI;
		this.BRAR_HUT = this.BRAR.HUT;
		this.BRAR_Rsvd2 = this.BRAR.Rsvd2;
		this.BRAR_Size = this.BRAR.Size;
		this.BRAR_Rsvd3 = this.BRAR.Rsvd3;
		this.BRAR_ST = this.BRAR.ST;
		this.ST = this.BRAR.ST;
		this.BRAR_Valid = this.BRAR.Valid;
      this.BRBLR = ral_reg_ncore_ioaiu_BRBLR::type_id::create("BRBLR",,get_full_name());
      this.BRBLR.configure(this, null, "");
      this.BRBLR.build();
      this.default_map.add_reg(this.BRBLR, `UVM_REG_ADDR_WIDTH'h804, "RW", 0);
		this.BRBLR_Address = this.BRBLR.Address;
      this.BRBHR = ral_reg_ncore_ioaiu_BRBHR::type_id::create("BRBHR",,get_full_name());
      this.BRBHR.configure(this, null, "");
      this.BRBHR.build();
      this.default_map.add_reg(this.BRBHR, `UVM_REG_ADDR_WIDTH'h808, "RW", 0);
		this.BRBHR_Address = this.BRBHR.Address;
		this.BRBHR_Rsvd1 = this.BRBHR.Rsvd1;
      this.NRSBAR = ral_reg_ncore_ioaiu_NRSBAR::type_id::create("NRSBAR",,get_full_name());
      this.NRSBAR.configure(this, null, "");
      this.NRSBAR.build();
      this.default_map.add_reg(this.NRSBAR, `UVM_REG_ADDR_WIDTH'h80C, "RW", 0);
		this.NRSBAR_NRSBA = this.NRSBAR.NRSBA;
		this.NRSBA = this.NRSBAR.NRSBA;
      this.AMIGR = ral_reg_ncore_ioaiu_AMIGR::type_id::create("AMIGR",,get_full_name());
      this.AMIGR.configure(this, null, "");
      this.AMIGR.build();
      this.default_map.add_reg(this.AMIGR, `UVM_REG_ADDR_WIDTH'h810, "RW", 0);
		this.AMIGR_Valid = this.AMIGR.Valid;
		this.AMIGR_AMIGS = this.AMIGR.AMIGS;
		this.AMIGS = this.AMIGR.AMIGS;
		this.AMIGR_Rsvd1 = this.AMIGR.Rsvd1;
      this.MAIFR = ral_reg_ncore_ioaiu_MAIFR::type_id::create("MAIFR",,get_full_name());
      this.MAIFR.configure(this, null, "");
      this.MAIFR.build();
      this.default_map.add_reg(this.MAIFR, `UVM_REG_ADDR_WIDTH'h814, "RW", 0);
		this.MAIFR_Rsvd1 = this.MAIFR.Rsvd1;
		this.MAIFR_MIG2AIFId = this.MAIFR.MIG2AIFId;
		this.MIG2AIFId = this.MAIFR.MIG2AIFId;
		this.MAIFR_MIG3AIFId = this.MAIFR.MIG3AIFId;
		this.MIG3AIFId = this.MAIFR.MIG3AIFId;
		this.MAIFR_MIG4AIFId = this.MAIFR.MIG4AIFId;
		this.MIG4AIFId = this.MAIFR.MIG4AIFId;
		this.MAIFR_Rsvd2 = this.MAIFR.Rsvd2;
      this.UENGIDR = ral_reg_ncore_ioaiu_UENGIDR::type_id::create("UENGIDR",,get_full_name());
      this.UENGIDR.configure(this, null, "");
      this.UENGIDR.build();
      this.default_map.add_reg(this.UENGIDR, `UVM_REG_ADDR_WIDTH'hFF4, "RO", 0);
		this.UENGIDR_EngVerId = this.UENGIDR.EngVerId;
		this.EngVerId = this.UENGIDR.EngVerId;
      this.UINFOR = ral_reg_ncore_ioaiu_UINFOR::type_id::create("UINFOR",,get_full_name());
      this.UINFOR.configure(this, null, "");
      this.UINFOR.build();
      this.default_map.add_reg(this.UINFOR, `UVM_REG_ADDR_WIDTH'hFFC, "RO", 0);
		this.UINFOR_ImplVer = this.UINFOR.ImplVer;
		this.ImplVer = this.UINFOR.ImplVer;
		this.UINFOR_UT = this.UINFOR.UT;
		this.UT = this.UINFOR.UT;
		this.UINFOR_Rsvd1 = this.UINFOR.Rsvd1;
		this.UINFOR_Valid = this.UINFOR.Valid;
   endfunction : build

	`uvm_object_utils(ral_block_ncore_ioaiu)

endclass : ral_block_ncore_ioaiu


class ral_sys_ncore extends uvm_reg_block;

   rand ral_block_ncore_ioaiu ioaiu;

	function new(string name = "ncore");
		super.new(name);
	endfunction: new

	function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.ioaiu = ral_block_ncore_ioaiu::type_id::create("ioaiu",,get_full_name());
      this.ioaiu.configure(this, "");
      this.ioaiu.build();
      this.default_map.add_submap(this.ioaiu.default_map, `UVM_REG_ADDR_WIDTH'h0);
	endfunction : build

	`uvm_object_utils(ral_sys_ncore)
endclass : ral_sys_ncore



`endif
