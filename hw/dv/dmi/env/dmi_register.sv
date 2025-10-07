`ifndef RAL_COHERENT_MEMORY_INTERFACE_UNIT
`define RAL_COHERENT_MEMORY_INTERFACE_UNIT

import uvm_pkg::*;

class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUTAR extends uvm_reg;
	uvm_reg_field TransActv;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUTAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.TransActv = uvm_reg_field::type_id::create("TransActv",,get_full_name());
      this.TransActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 31, 1, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUTAR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUTAR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTCR extends uvm_reg;
	rand uvm_reg_field LookupEn;
	rand uvm_reg_field FillEn;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
  <% if (obj.useCmc) { %>
      this.LookupEn = uvm_reg_field::type_id::create("LookupEn",,get_full_name());
      this.LookupEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.FillEn = uvm_reg_field::type_id::create("FillEn",,get_full_name());
      this.FillEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
  <%} else { %>
      this.LookupEn = uvm_reg_field::type_id::create("LookupEn",,get_full_name());
      this.LookupEn.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.FillEn = uvm_reg_field::type_id::create("FillEn",,get_full_name());
      this.FillEn.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
  <% } %>
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 30, 2, "RO", 0, 30'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTCR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTCR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTAR extends uvm_reg;
	uvm_reg_field EvictActv;
	uvm_reg_field FillActv;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.EvictActv = uvm_reg_field::type_id::create("EvictActv",,get_full_name());
      this.EvictActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.FillActv = uvm_reg_field::type_id::create("FillActv",,get_full_name());
      this.FillActv.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 30, 2, "RO", 0, 30'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTAR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTAR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMCR extends uvm_reg;
	rand uvm_reg_field CmcMntOp;
	rand uvm_reg_field CmcArrId;
	rand uvm_reg_field CmcSecAttr;
	uvm_reg_field rsvd1;
	uvm_reg_field rsvd2;
	uvm_reg_field rsvd3;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
  <% if (obj.useCmc) { %>
      this.CmcMntOp = uvm_reg_field::type_id::create("CmcMntOp",,get_full_name());
      this.CmcMntOp.configure(this, 4, 0, "RW", 0, 4'h0, 1, 0, 0);
      this.CmcArrId = uvm_reg_field::type_id::create("CmcArrId",,get_full_name());
      this.CmcArrId.configure(this, 1, 16, "RW", 0, 1'h0, 1, 0, 0);
      this.CmcSecAttr = uvm_reg_field::type_id::create("CmcSecAttr",,get_full_name());
      this.CmcSecAttr.configure(this, 1, 21, "RW", 0, 1'h0, 1, 0, 0);
  <% } else { %>
      this.CmcMntOp = uvm_reg_field::type_id::create("CmcMntOp",,get_full_name());
      this.CmcMntOp.configure(this, 4, 0, "RO", 0, 4'h0, 1, 0, 0);
      this.CmcArrId = uvm_reg_field::type_id::create("CmcArrId",,get_full_name());
      this.CmcArrId.configure(this, 1, 16, "RO", 0, 1'h0, 1, 0, 0);
      this.CmcSecAttr = uvm_reg_field::type_id::create("CmcSecAttr",,get_full_name());
      this.CmcSecAttr.configure(this, 1, 21, "RO", 0, 1'h0, 1, 0, 0);
  <% } %>
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 12, 4, "RO", 0, 12'h0, 1, 0, 0);
      this.rsvd2 = uvm_reg_field::type_id::create("rsvd2",,get_full_name());
      this.rsvd2.configure(this, 4, 17, "RO", 0, 4'h0, 1, 0, 0);
      this.rsvd3 = uvm_reg_field::type_id::create("rsvd3",,get_full_name());
      this.rsvd3.configure(this, 10, 22, "RO", 0, 10'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMCR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMCR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMAR extends uvm_reg;
	uvm_reg_field MntOpActv;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.MntOpActv = uvm_reg_field::type_id::create("MntOpActv",,get_full_name());
      this.MntOpActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 31, 1, "RO", 0, 31'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMAR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMAR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR0 extends uvm_reg;
	rand uvm_reg_field MntSet;
	rand uvm_reg_field MntWay;
	rand uvm_reg_field MntWord;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
  <% if (obj.useCmc) { %>
      this.MntSet = uvm_reg_field::type_id::create("MntSet",,get_full_name());
      this.MntSet.configure(this, 20, 0, "RW", 0, 20'h0, 1, 0, 0);
      this.MntWay = uvm_reg_field::type_id::create("MntWay",,get_full_name());
      this.MntWay.configure(this, 6, 20, "RW", 0, 6'h0, 1, 0, 0);
      this.MntWord = uvm_reg_field::type_id::create("MntWord",,get_full_name());
      this.MntWord.configure(this, 6, 26, "RW", 0, 6'h0, 1, 0, 0);
  <% } else { %>
      this.MntSet = uvm_reg_field::type_id::create("MntSet",,get_full_name());
      this.MntSet.configure(this, 20, 0, "RO", 0, 20'h0, 1, 0, 0);
      this.MntWay = uvm_reg_field::type_id::create("MntWay",,get_full_name());
      this.MntWay.configure(this, 6, 20, "RO", 0, 6'h0, 1, 0, 0);
      this.MntWord = uvm_reg_field::type_id::create("MntWord",,get_full_name());
      this.MntWord.configure(this, 6, 26, "RO", 0, 6'h0, 1, 0, 0);
  <% } %>
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR0)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR0


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR1 extends uvm_reg;
	rand uvm_reg_field MntAddr;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
  <% if (obj.useCmc) { %>
      this.MntAddr = uvm_reg_field::type_id::create("MntAddr",,get_full_name());
      this.MntAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
  <% } else { %>
      this.MntAddr = uvm_reg_field::type_id::create("MntAddr",,get_full_name());
      this.MntAddr.configure(this, 12, 0, "RO", 0, 12'h0, 1, 0, 0);
  <% } %>
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR1)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR1


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMDR extends uvm_reg;
	rand uvm_reg_field MntData;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
  <% if (obj.useCmc) { %>
      this.MntData = uvm_reg_field::type_id::create("MntData",,get_full_name());
      this.MntData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
  <% } else { %>
      this.MntData = uvm_reg_field::type_id::create("MntData",,get_full_name());
      this.MntData.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
  <% } %>
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMDR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMDR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCECR extends uvm_reg;
	rand uvm_reg_field ErrDetEn;
	rand uvm_reg_field ErrIntEn;
	rand uvm_reg_field ErrThreshold;
	uvm_reg_field rsvd1;
	uvm_reg_field rsvd2;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCECR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrDetEn = uvm_reg_field::type_id::create("ErrDetEn",,get_full_name());
      this.ErrDetEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrIntEn = uvm_reg_field::type_id::create("ErrIntEn",,get_full_name());
      this.ErrIntEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrThreshold = uvm_reg_field::type_id::create("ErrThreshold",,get_full_name());
      this.ErrThreshold.configure(this, 8, 4, "RW", 0, 8'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.rsvd2 = uvm_reg_field::type_id::create("rsvd2",,get_full_name());
      this.rsvd2.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCECR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCECR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	uvm_reg_field ErrCount;
	uvm_reg_field ErrType;
	uvm_reg_field ErrInfo;
	uvm_reg_field rsvd1;
	uvm_reg_field rsvd2;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "W1", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "W1", 0, 1'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RO", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RO", 0, 8'h0, 1, 0, 1);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.rsvd2 = uvm_reg_field::type_id::create("rsvd2",,get_full_name());
      this.rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR0 extends uvm_reg;
	rand uvm_reg_field ErrEntry;
	rand uvm_reg_field ErrWay;
	rand uvm_reg_field ErrWord;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR0");
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

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR0)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR0


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR1)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR1


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	rand uvm_reg_field ErrCount;
	rand uvm_reg_field ErrType;
	rand uvm_reg_field ErrInfo;
	uvm_reg_field rsvd1;
	uvm_reg_field rsvd2;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RW", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RW", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.rsvd2 = uvm_reg_field::type_id::create("rsvd2",,get_full_name());
      this.rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESAR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESAR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUECR extends uvm_reg;
	rand uvm_reg_field ErrDetEn;
	rand uvm_reg_field ErrIntEn;
	uvm_reg_field ErrThreshold;
	uvm_reg_field rsvd1;
	uvm_reg_field rsvd2;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUUECR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrDetEn = uvm_reg_field::type_id::create("ErrDetEn",,get_full_name());
      this.ErrDetEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrIntEn = uvm_reg_field::type_id::create("ErrIntEn",,get_full_name());
      this.ErrIntEn.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrThreshold = uvm_reg_field::type_id::create("ErrThreshold",,get_full_name());
      this.ErrThreshold.configure(this, 8, 4, "RO", 0, 8'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.rsvd2 = uvm_reg_field::type_id::create("rsvd2",,get_full_name());
      this.rsvd2.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUECR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUECR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	uvm_reg_field ErrCount;
	uvm_reg_field ErrType;
	uvm_reg_field ErrInfo;
	uvm_reg_field rsvd1;
	uvm_reg_field rsvd2;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "W1", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "W1", 0, 1'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RO", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RO", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RO", 0, 8'h0, 1, 0, 1);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.rsvd2 = uvm_reg_field::type_id::create("rsvd2",,get_full_name());
      this.rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR0 extends uvm_reg;
	rand uvm_reg_field ErrEntry;
	rand uvm_reg_field ErrWay;
	rand uvm_reg_field ErrWord;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR0");
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

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR0)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR0


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR1 extends uvm_reg;
	rand uvm_reg_field ErrAddr;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrAddr = uvm_reg_field::type_id::create("ErrAddr",,get_full_name());
      this.ErrAddr.configure(this, 12, 0, "RW", 0, 12'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 20, 12, "RO", 0, 20'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR1)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR1


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESAR extends uvm_reg;
	rand uvm_reg_field ErrVld;
	rand uvm_reg_field ErrOvf;
	rand uvm_reg_field ErrCount;
	rand uvm_reg_field ErrType;
	rand uvm_reg_field ErrInfo;
	uvm_reg_field rsvd1;
	uvm_reg_field rsvd2;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrVld = uvm_reg_field::type_id::create("ErrVld",,get_full_name());
      this.ErrVld.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrOvf = uvm_reg_field::type_id::create("ErrOvf",,get_full_name());
      this.ErrOvf.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
      this.ErrCount = uvm_reg_field::type_id::create("ErrCount",,get_full_name());
      this.ErrCount.configure(this, 8, 4, "RW", 0, 8'h0, 1, 0, 0);
      this.ErrType = uvm_reg_field::type_id::create("ErrType",,get_full_name());
      this.ErrType.configure(this, 4, 12, "RW", 0, 4'h0, 1, 0, 0);
      this.ErrInfo = uvm_reg_field::type_id::create("ErrInfo",,get_full_name());
      this.ErrInfo.configure(this, 8, 16, "RW", 0, 8'h0, 1, 0, 1);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 2, 2, "RO", 0, 2'h0, 1, 0, 0);
      this.rsvd2 = uvm_reg_field::type_id::create("rsvd2",,get_full_name());
      this.rsvd2.configure(this, 8, 24, "RO", 0, 8'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESAR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESAR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDCR extends uvm_reg;
	rand uvm_reg_field DbgOp;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUDCR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DbgOp = uvm_reg_field::type_id::create("DbgOp",,get_full_name());
      this.DbgOp.configure(this, 4, 0, "RW", 0, 4'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 28, 4, "RO", 0, 28'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDCR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDCR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDAR extends uvm_reg;
	uvm_reg_field DbgOpActv;
	uvm_reg_field DbgOpFail;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUDAR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DbgOpActv = uvm_reg_field::type_id::create("DbgOpActv",,get_full_name());
      this.DbgOpActv.configure(this, 1, 0, "RO", 0, 1'h0, 1, 0, 0);
      this.DbgOpFail = uvm_reg_field::type_id::create("DbgOpFail",,get_full_name());
      this.DbgOpFail.configure(this, 1, 1, "RO", 0, 1'h0, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 30, 2, "RO", 0, 30'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDAR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDAR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDLR extends uvm_reg;
	rand uvm_reg_field DbgEntry;
	rand uvm_reg_field DbgStruct;
	rand uvm_reg_field DbgWord;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUDLR");
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

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDLR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDLR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDDR extends uvm_reg;
	uvm_reg_field DbgData;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUDDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DbgData = uvm_reg_field::type_id::create("DbgData",,get_full_name());
      this.DbgData.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDDR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDDR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCIDR extends uvm_reg;
	uvm_reg_field NumSets;
	uvm_reg_field NumWays;
	uvm_reg_field Type;
	uvm_reg_field rsvd1;


    <% 
        var cmiu_cmc_numSets;
        var cmiu_cmc_numWays;
        if(obj.useCmc){
            cmiu_cmc_numSets = (obj.DmiInfo[obj.logicalId].CacheInfo.nSets-1).toString(16);
            cmiu_cmc_numWays = (obj.DmiInfo[obj.logicalId].CacheInfo.nWays-1).toString(16);
        }

    %>


	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
       <% if (obj.useCmc) { %>
      this.NumSets = uvm_reg_field::type_id::create("NumSets",,get_full_name());
      this.NumSets.configure(this, 20, 0, "RO", 0, 20'h<%=cmiu_cmc_numSets%>, 1, 0, 0);
      this.NumWays = uvm_reg_field::type_id::create("NumWays",,get_full_name());
      this.NumWays.configure(this, 6, 20, "RO", 0, 6'h<%=cmiu_cmc_numWays%>, 1, 0, 0);
      this.Type = uvm_reg_field::type_id::create("Type",,get_full_name());
      <% if (obj.DmiInfo[obj.logicalId].useAllocDtwData == 0) { %>
      this.Type.configure(this, 3, 26, "RO", 0, 3'h1, 1, 0, 0);
      <% } else if (obj.DmiInfo[obj.logicalId].useAllocDtwData == 1) { %>
      this.Type.configure(this, 3, 26, "RO", 0, 3'h2, 1, 0, 0);
      <% } else { %>
      this.Type.configure(this, 3, 26, "RO", 0, 3'h0, 1, 0, 0);
      <% } %>

      <%} else {%>
      this.NumSets = uvm_reg_field::type_id::create("NumSets",,get_full_name());
      this.NumSets.configure(this, 20, 0, "RO", 0, 0, 1, 0, 0);
      this.NumWays = uvm_reg_field::type_id::create("NumWays",,get_full_name());
      this.NumWays.configure(this, 6, 20, "RO", 0, 0, 1, 0, 0);
      this.Type = uvm_reg_field::type_id::create("Type",,get_full_name());
      this.Type.configure(this, 3, 26, "RO", 0, 3'h0, 1, 0, 0);
      <% } %>

      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 3, 29, "RO", 0, 3'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCIDR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCIDR


class ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUIDR extends uvm_reg;
	uvm_reg_field ImplVer;
	uvm_reg_field CmiId;
	uvm_reg_field HntCap;
	uvm_reg_field Cmc;
	uvm_reg_field rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit_CMIUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ImplVer = uvm_reg_field::type_id::create("ImplVer",,get_full_name());
      this.ImplVer.configure(this, 8, 0, "RO", 0, 8'h1, 1, 0, 1);
      this.CmiId = uvm_reg_field::type_id::create("CmiId",,get_full_name());
      this.CmiId.configure(this, 5, 8, "RO", 0, 5'h0, 1, 0, 0);
      this.HntCap = uvm_reg_field::type_id::create("HntCap",,get_full_name());
      this.HntCap.configure(this, 1, 13, "RO", 0, <%=obj.useCmc%>, 1, 0, 0);
      this.Cmc = uvm_reg_field::type_id::create("Cmc",,get_full_name());
      this.Cmc.configure(this, 1, 31, "RO", 0, <%=obj.useCmc%>, 1, 0, 0);
      this.rsvd1 = uvm_reg_field::type_id::create("rsvd1",,get_full_name());
      this.rsvd1.configure(this, 17, 14, "RO", 0, 17'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUIDR)

endclass : ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUIDR


class ral_block_concerto_registers_Coherent_Memory_Interface_Unit extends uvm_reg_block;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUTAR CMIUTAR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTCR CMIUCMCTCR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTAR CMIUCMCTAR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMCR CMIUCMCMCR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMAR CMIUCMCMAR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR0 CMIUCMCMLR0;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR1 CMIUCMCMLR1;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMDR CMIUCMCMDR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCECR CMIUCECR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESR CMIUCESR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR0 CMIUCELR0;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR1 CMIUCELR1;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESAR CMIUCESAR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUECR CMIUUECR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESR CMIUUESR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR0 CMIUUELR0;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR1 CMIUUELR1;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESAR CMIUUESAR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDCR CMIUDCR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDAR CMIUDAR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDLR CMIUDLR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDDR CMIUDDR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCIDR CMIUCMCIDR;
	rand ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUIDR CMIUIDR;
	uvm_reg_field CMIUTAR_TransActv;
	uvm_reg_field TransActv;
	uvm_reg_field CMIUTAR_rsvd1;
	rand uvm_reg_field CMIUCMCTCR_LookupEn;
	rand uvm_reg_field LookupEn;
	rand uvm_reg_field CMIUCMCTCR_FillEn;
	rand uvm_reg_field FillEn;
	uvm_reg_field CMIUCMCTCR_rsvd1;
	uvm_reg_field CMIUCMCTAR_EvictActv;
	uvm_reg_field EvictActv;
	uvm_reg_field CMIUCMCTAR_FillActv;
	uvm_reg_field FillActv;
	uvm_reg_field CMIUCMCTAR_rsvd1;
	rand uvm_reg_field CMIUCMCMCR_CmcMntOp;
	rand uvm_reg_field CmcMntOp;
	rand uvm_reg_field CMIUCMCMCR_CmcArrId;
	rand uvm_reg_field CmcArrId;
	rand uvm_reg_field CMIUCMCMCR_CmcSecAttr;
	rand uvm_reg_field CmcSecAttr;
	uvm_reg_field CMIUCMCMCR_rsvd1;
	uvm_reg_field CMIUCMCMCR_rsvd2;
	uvm_reg_field CMIUCMCMCR_rsvd3;
	uvm_reg_field rsvd3;
	uvm_reg_field CMIUCMCMAR_MntOpActv;
	uvm_reg_field MntOpActv;
	uvm_reg_field CMIUCMCMAR_rsvd1;
	rand uvm_reg_field CMIUCMCMLR0_MntSet;
	rand uvm_reg_field MntSet;
	rand uvm_reg_field CMIUCMCMLR0_MntWay;
	rand uvm_reg_field MntWay;
	rand uvm_reg_field CMIUCMCMLR0_MntWord;
	rand uvm_reg_field MntWord;
	rand uvm_reg_field CMIUCMCMLR1_MntAddr;
	rand uvm_reg_field MntAddr;
	uvm_reg_field CMIUCMCMLR1_rsvd1;
	rand uvm_reg_field CMIUCMCMDR_MntData;
	rand uvm_reg_field MntData;
	rand uvm_reg_field CMIUCECR_ErrDetEn;
	rand uvm_reg_field CMIUCECR_ErrIntEn;
	rand uvm_reg_field CMIUCECR_ErrThreshold;
	uvm_reg_field CMIUCECR_rsvd1;
	uvm_reg_field CMIUCECR_rsvd2;
	rand uvm_reg_field CMIUCESR_ErrVld;
	rand uvm_reg_field CMIUCESR_ErrOvf;
	uvm_reg_field CMIUCESR_ErrCount;
	uvm_reg_field CMIUCESR_ErrType;
	uvm_reg_field CMIUCESR_ErrInfo;
	uvm_reg_field CMIUCESR_rsvd1;
	uvm_reg_field CMIUCESR_rsvd2;
	rand uvm_reg_field CMIUCELR0_ErrEntry;
	rand uvm_reg_field CMIUCELR0_ErrWay;
	rand uvm_reg_field CMIUCELR0_ErrWord;
	rand uvm_reg_field CMIUCELR1_ErrAddr;
	uvm_reg_field CMIUCELR1_rsvd1;
	rand uvm_reg_field CMIUCESAR_ErrVld;
	rand uvm_reg_field CMIUCESAR_ErrOvf;
	rand uvm_reg_field CMIUCESAR_ErrCount;
	rand uvm_reg_field CMIUCESAR_ErrType;
	rand uvm_reg_field CMIUCESAR_ErrInfo;
	uvm_reg_field CMIUCESAR_rsvd1;
	uvm_reg_field CMIUCESAR_rsvd2;
	rand uvm_reg_field CMIUUECR_ErrDetEn;
	rand uvm_reg_field CMIUUECR_ErrIntEn;
	uvm_reg_field CMIUUECR_ErrThreshold;
	uvm_reg_field CMIUUECR_rsvd1;
	uvm_reg_field CMIUUECR_rsvd2;
	rand uvm_reg_field CMIUUESR_ErrVld;
	rand uvm_reg_field CMIUUESR_ErrOvf;
	uvm_reg_field CMIUUESR_ErrCount;
	uvm_reg_field CMIUUESR_ErrType;
	uvm_reg_field CMIUUESR_ErrInfo;
	uvm_reg_field CMIUUESR_rsvd1;
	uvm_reg_field CMIUUESR_rsvd2;
	rand uvm_reg_field CMIUUELR0_ErrEntry;
	rand uvm_reg_field CMIUUELR0_ErrWay;
	rand uvm_reg_field CMIUUELR0_ErrWord;
	rand uvm_reg_field CMIUUELR1_ErrAddr;
	uvm_reg_field CMIUUELR1_rsvd1;
	rand uvm_reg_field CMIUUESAR_ErrVld;
	rand uvm_reg_field CMIUUESAR_ErrOvf;
	rand uvm_reg_field CMIUUESAR_ErrCount;
	rand uvm_reg_field CMIUUESAR_ErrType;
	rand uvm_reg_field CMIUUESAR_ErrInfo;
	uvm_reg_field CMIUUESAR_rsvd1;
	uvm_reg_field CMIUUESAR_rsvd2;
	rand uvm_reg_field CMIUDCR_DbgOp;
	rand uvm_reg_field DbgOp;
	uvm_reg_field CMIUDCR_rsvd1;
	uvm_reg_field CMIUDAR_DbgOpActv;
	uvm_reg_field DbgOpActv;
	uvm_reg_field CMIUDAR_DbgOpFail;
	uvm_reg_field DbgOpFail;
	uvm_reg_field CMIUDAR_rsvd1;
	rand uvm_reg_field CMIUDLR_DbgEntry;
	rand uvm_reg_field DbgEntry;
	rand uvm_reg_field CMIUDLR_DbgStruct;
	rand uvm_reg_field DbgStruct;
	rand uvm_reg_field CMIUDLR_DbgWord;
	rand uvm_reg_field DbgWord;
	uvm_reg_field CMIUDDR_DbgData;
	uvm_reg_field DbgData;
	uvm_reg_field CMIUCMCIDR_NumSets;
	uvm_reg_field NumSets;
	uvm_reg_field CMIUCMCIDR_NumWays;
	uvm_reg_field NumWays;
	uvm_reg_field CMIUCMCIDR_Type;
	uvm_reg_field Type;
	uvm_reg_field CMIUCMCIDR_rsvd1;
	uvm_reg_field CMIUIDR_ImplVer;
	uvm_reg_field ImplVer;
	uvm_reg_field CMIUIDR_CmiId;
	uvm_reg_field CmiId;
	uvm_reg_field CMIUIDR_HntCap;
	uvm_reg_field HntCap;
	uvm_reg_field CMIUIDR_Cmc;
	uvm_reg_field Cmc;
	uvm_reg_field CMIUIDR_rsvd1;

	function new(string name = "concerto_registers_Coherent_Memory_Interface_Unit");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.CMIUTAR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUTAR::type_id::create("CMIUTAR",,get_full_name());
      this.CMIUTAR.configure(this, null, "");
      this.CMIUTAR.build();
      this.default_map.add_reg(this.CMIUTAR, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);
		this.CMIUTAR_TransActv = this.CMIUTAR.TransActv;
		this.TransActv = this.CMIUTAR.TransActv;
		this.CMIUTAR_rsvd1 = this.CMIUTAR.rsvd1;
      this.CMIUCMCTCR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTCR::type_id::create("CMIUCMCTCR",,get_full_name());
      this.CMIUCMCTCR.configure(this, null, "");
      this.CMIUCMCTCR.build();
      this.default_map.add_reg(this.CMIUCMCTCR, `UVM_REG_ADDR_WIDTH'h10, "RW", 0);
		this.CMIUCMCTCR_LookupEn = this.CMIUCMCTCR.LookupEn;
		this.LookupEn = this.CMIUCMCTCR.LookupEn;
		this.CMIUCMCTCR_FillEn = this.CMIUCMCTCR.FillEn;
		this.FillEn = this.CMIUCMCTCR.FillEn;
		this.CMIUCMCTCR_rsvd1 = this.CMIUCMCTCR.rsvd1;
      this.CMIUCMCTAR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCTAR::type_id::create("CMIUCMCTAR",,get_full_name());
      this.CMIUCMCTAR.configure(this, null, "");
      this.CMIUCMCTAR.build();
      this.default_map.add_reg(this.CMIUCMCTAR, `UVM_REG_ADDR_WIDTH'h14, "RO", 0);
		this.CMIUCMCTAR_EvictActv = this.CMIUCMCTAR.EvictActv;
		this.EvictActv = this.CMIUCMCTAR.EvictActv;
		this.CMIUCMCTAR_FillActv = this.CMIUCMCTAR.FillActv;
		this.FillActv = this.CMIUCMCTAR.FillActv;
		this.CMIUCMCTAR_rsvd1 = this.CMIUCMCTAR.rsvd1;
      this.CMIUCMCMCR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMCR::type_id::create("CMIUCMCMCR",,get_full_name());
      this.CMIUCMCMCR.configure(this, null, "");
      this.CMIUCMCMCR.build();
      this.default_map.add_reg(this.CMIUCMCMCR, `UVM_REG_ADDR_WIDTH'h80, "RW", 0);
		this.CMIUCMCMCR_CmcMntOp = this.CMIUCMCMCR.CmcMntOp;
		this.CmcMntOp = this.CMIUCMCMCR.CmcMntOp;
		this.CMIUCMCMCR_CmcArrId = this.CMIUCMCMCR.CmcArrId;
		this.CmcArrId = this.CMIUCMCMCR.CmcArrId;
		this.CMIUCMCMCR_CmcSecAttr = this.CMIUCMCMCR.CmcSecAttr;
		this.CmcSecAttr = this.CMIUCMCMCR.CmcSecAttr;
		this.CMIUCMCMCR_rsvd1 = this.CMIUCMCMCR.rsvd1;
		this.CMIUCMCMCR_rsvd2 = this.CMIUCMCMCR.rsvd2;
		this.CMIUCMCMCR_rsvd3 = this.CMIUCMCMCR.rsvd3;
		this.rsvd3 = this.CMIUCMCMCR.rsvd3;
      this.CMIUCMCMAR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMAR::type_id::create("CMIUCMCMAR",,get_full_name());
      this.CMIUCMCMAR.configure(this, null, "");
      this.CMIUCMCMAR.build();
      this.default_map.add_reg(this.CMIUCMCMAR, `UVM_REG_ADDR_WIDTH'h84, "RO", 0);
		this.CMIUCMCMAR_MntOpActv = this.CMIUCMCMAR.MntOpActv;
		this.MntOpActv = this.CMIUCMCMAR.MntOpActv;
		this.CMIUCMCMAR_rsvd1 = this.CMIUCMCMAR.rsvd1;
      this.CMIUCMCMLR0 = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR0::type_id::create("CMIUCMCMLR0",,get_full_name());
      this.CMIUCMCMLR0.configure(this, null, "");
      this.CMIUCMCMLR0.build();
      this.default_map.add_reg(this.CMIUCMCMLR0, `UVM_REG_ADDR_WIDTH'h88, "RW", 0);
		this.CMIUCMCMLR0_MntSet = this.CMIUCMCMLR0.MntSet;
		this.MntSet = this.CMIUCMCMLR0.MntSet;
		this.CMIUCMCMLR0_MntWay = this.CMIUCMCMLR0.MntWay;
		this.MntWay = this.CMIUCMCMLR0.MntWay;
		this.CMIUCMCMLR0_MntWord = this.CMIUCMCMLR0.MntWord;
		this.MntWord = this.CMIUCMCMLR0.MntWord;
      this.CMIUCMCMLR1 = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMLR1::type_id::create("CMIUCMCMLR1",,get_full_name());
      this.CMIUCMCMLR1.configure(this, null, "");
      this.CMIUCMCMLR1.build();
      this.default_map.add_reg(this.CMIUCMCMLR1, `UVM_REG_ADDR_WIDTH'h8C, "RW", 0);
		this.CMIUCMCMLR1_MntAddr = this.CMIUCMCMLR1.MntAddr;
		this.MntAddr = this.CMIUCMCMLR1.MntAddr;
		this.CMIUCMCMLR1_rsvd1 = this.CMIUCMCMLR1.rsvd1;
      this.CMIUCMCMDR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCMDR::type_id::create("CMIUCMCMDR",,get_full_name());
      this.CMIUCMCMDR.configure(this, null, "");
      this.CMIUCMCMDR.build();
      this.default_map.add_reg(this.CMIUCMCMDR, `UVM_REG_ADDR_WIDTH'h90, "RW", 0);
		this.CMIUCMCMDR_MntData = this.CMIUCMCMDR.MntData;
		this.MntData = this.CMIUCMCMDR.MntData;
      this.CMIUCECR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCECR::type_id::create("CMIUCECR",,get_full_name());
      this.CMIUCECR.configure(this, null, "");
      this.CMIUCECR.build();
      this.default_map.add_reg(this.CMIUCECR, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
		this.CMIUCECR_ErrDetEn = this.CMIUCECR.ErrDetEn;
		this.CMIUCECR_ErrIntEn = this.CMIUCECR.ErrIntEn;
		this.CMIUCECR_ErrThreshold = this.CMIUCECR.ErrThreshold;
		this.CMIUCECR_rsvd1 = this.CMIUCECR.rsvd1;
		this.CMIUCECR_rsvd2 = this.CMIUCECR.rsvd2;
      this.CMIUCESR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESR::type_id::create("CMIUCESR",,get_full_name());
      this.CMIUCESR.configure(this, null, "");
      this.CMIUCESR.build();
      this.default_map.add_reg(this.CMIUCESR, `UVM_REG_ADDR_WIDTH'h104, "RW", 0);
		this.CMIUCESR_ErrVld = this.CMIUCESR.ErrVld;
		this.CMIUCESR_ErrOvf = this.CMIUCESR.ErrOvf;
		this.CMIUCESR_ErrCount = this.CMIUCESR.ErrCount;
		this.CMIUCESR_ErrType = this.CMIUCESR.ErrType;
		this.CMIUCESR_ErrInfo = this.CMIUCESR.ErrInfo;
		this.CMIUCESR_rsvd1 = this.CMIUCESR.rsvd1;
		this.CMIUCESR_rsvd2 = this.CMIUCESR.rsvd2;
      this.CMIUCELR0 = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR0::type_id::create("CMIUCELR0",,get_full_name());
      this.CMIUCELR0.configure(this, null, "");
      this.CMIUCELR0.build();
      this.default_map.add_reg(this.CMIUCELR0, `UVM_REG_ADDR_WIDTH'h108, "RW", 0);
		this.CMIUCELR0_ErrEntry = this.CMIUCELR0.ErrEntry;
		this.CMIUCELR0_ErrWay = this.CMIUCELR0.ErrWay;
		this.CMIUCELR0_ErrWord = this.CMIUCELR0.ErrWord;
      this.CMIUCELR1 = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCELR1::type_id::create("CMIUCELR1",,get_full_name());
      this.CMIUCELR1.configure(this, null, "");
      this.CMIUCELR1.build();
      this.default_map.add_reg(this.CMIUCELR1, `UVM_REG_ADDR_WIDTH'h10C, "RW", 0);
		this.CMIUCELR1_ErrAddr = this.CMIUCELR1.ErrAddr;
		this.CMIUCELR1_rsvd1 = this.CMIUCELR1.rsvd1;
      this.CMIUCESAR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCESAR::type_id::create("CMIUCESAR",,get_full_name());
      this.CMIUCESAR.configure(this, null, "");
      this.CMIUCESAR.build();
      this.default_map.add_reg(this.CMIUCESAR, `UVM_REG_ADDR_WIDTH'h124, "RW", 0);
		this.CMIUCESAR_ErrVld = this.CMIUCESAR.ErrVld;
		this.CMIUCESAR_ErrOvf = this.CMIUCESAR.ErrOvf;
		this.CMIUCESAR_ErrCount = this.CMIUCESAR.ErrCount;
		this.CMIUCESAR_ErrType = this.CMIUCESAR.ErrType;
		this.CMIUCESAR_ErrInfo = this.CMIUCESAR.ErrInfo;
		this.CMIUCESAR_rsvd1 = this.CMIUCESAR.rsvd1;
		this.CMIUCESAR_rsvd2 = this.CMIUCESAR.rsvd2;
      this.CMIUUECR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUECR::type_id::create("CMIUUECR",,get_full_name());
      this.CMIUUECR.configure(this, null, "");
      this.CMIUUECR.build();
      this.default_map.add_reg(this.CMIUUECR, `UVM_REG_ADDR_WIDTH'h140, "RW", 0);
		this.CMIUUECR_ErrDetEn = this.CMIUUECR.ErrDetEn;
		this.CMIUUECR_ErrIntEn = this.CMIUUECR.ErrIntEn;
		this.CMIUUECR_ErrThreshold = this.CMIUUECR.ErrThreshold;
		this.CMIUUECR_rsvd1 = this.CMIUUECR.rsvd1;
		this.CMIUUECR_rsvd2 = this.CMIUUECR.rsvd2;
      this.CMIUUESR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESR::type_id::create("CMIUUESR",,get_full_name());
      this.CMIUUESR.configure(this, null, "");
      this.CMIUUESR.build();
      this.default_map.add_reg(this.CMIUUESR, `UVM_REG_ADDR_WIDTH'h144, "RW", 0);
		this.CMIUUESR_ErrVld = this.CMIUUESR.ErrVld;
		this.CMIUUESR_ErrOvf = this.CMIUUESR.ErrOvf;
		this.CMIUUESR_ErrCount = this.CMIUUESR.ErrCount;
		this.CMIUUESR_ErrType = this.CMIUUESR.ErrType;
		this.CMIUUESR_ErrInfo = this.CMIUUESR.ErrInfo;
		this.CMIUUESR_rsvd1 = this.CMIUUESR.rsvd1;
		this.CMIUUESR_rsvd2 = this.CMIUUESR.rsvd2;
      this.CMIUUELR0 = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR0::type_id::create("CMIUUELR0",,get_full_name());
      this.CMIUUELR0.configure(this, null, "");
      this.CMIUUELR0.build();
      this.default_map.add_reg(this.CMIUUELR0, `UVM_REG_ADDR_WIDTH'h148, "RW", 0);
		this.CMIUUELR0_ErrEntry = this.CMIUUELR0.ErrEntry;
		this.CMIUUELR0_ErrWay = this.CMIUUELR0.ErrWay;
		this.CMIUUELR0_ErrWord = this.CMIUUELR0.ErrWord;
      this.CMIUUELR1 = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUELR1::type_id::create("CMIUUELR1",,get_full_name());
      this.CMIUUELR1.configure(this, null, "");
      this.CMIUUELR1.build();
      this.default_map.add_reg(this.CMIUUELR1, `UVM_REG_ADDR_WIDTH'h14C, "RW", 0);
		this.CMIUUELR1_ErrAddr = this.CMIUUELR1.ErrAddr;
		this.CMIUUELR1_rsvd1 = this.CMIUUELR1.rsvd1;
      this.CMIUUESAR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUUESAR::type_id::create("CMIUUESAR",,get_full_name());
      this.CMIUUESAR.configure(this, null, "");
      this.CMIUUESAR.build();
      this.default_map.add_reg(this.CMIUUESAR, `UVM_REG_ADDR_WIDTH'h164, "RW", 0);
		this.CMIUUESAR_ErrVld = this.CMIUUESAR.ErrVld;
		this.CMIUUESAR_ErrOvf = this.CMIUUESAR.ErrOvf;
		this.CMIUUESAR_ErrCount = this.CMIUUESAR.ErrCount;
		this.CMIUUESAR_ErrType = this.CMIUUESAR.ErrType;
		this.CMIUUESAR_ErrInfo = this.CMIUUESAR.ErrInfo;
		this.CMIUUESAR_rsvd1 = this.CMIUUESAR.rsvd1;
		this.CMIUUESAR_rsvd2 = this.CMIUUESAR.rsvd2;
      this.CMIUDCR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDCR::type_id::create("CMIUDCR",,get_full_name());
      this.CMIUDCR.configure(this, null, "");
      this.CMIUDCR.build();
      this.default_map.add_reg(this.CMIUDCR, `UVM_REG_ADDR_WIDTH'hF00, "RW", 0);
		this.CMIUDCR_DbgOp = this.CMIUDCR.DbgOp;
		this.DbgOp = this.CMIUDCR.DbgOp;
		this.CMIUDCR_rsvd1 = this.CMIUDCR.rsvd1;
      this.CMIUDAR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDAR::type_id::create("CMIUDAR",,get_full_name());
      this.CMIUDAR.configure(this, null, "");
      this.CMIUDAR.build();
      this.default_map.add_reg(this.CMIUDAR, `UVM_REG_ADDR_WIDTH'hF04, "RO", 0);
		this.CMIUDAR_DbgOpActv = this.CMIUDAR.DbgOpActv;
		this.DbgOpActv = this.CMIUDAR.DbgOpActv;
		this.CMIUDAR_DbgOpFail = this.CMIUDAR.DbgOpFail;
		this.DbgOpFail = this.CMIUDAR.DbgOpFail;
		this.CMIUDAR_rsvd1 = this.CMIUDAR.rsvd1;
      this.CMIUDLR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDLR::type_id::create("CMIUDLR",,get_full_name());
      this.CMIUDLR.configure(this, null, "");
      this.CMIUDLR.build();
      this.default_map.add_reg(this.CMIUDLR, `UVM_REG_ADDR_WIDTH'hF08, "RW", 0);
		this.CMIUDLR_DbgEntry = this.CMIUDLR.DbgEntry;
		this.DbgEntry = this.CMIUDLR.DbgEntry;
		this.CMIUDLR_DbgStruct = this.CMIUDLR.DbgStruct;
		this.DbgStruct = this.CMIUDLR.DbgStruct;
		this.CMIUDLR_DbgWord = this.CMIUDLR.DbgWord;
		this.DbgWord = this.CMIUDLR.DbgWord;
      this.CMIUDDR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUDDR::type_id::create("CMIUDDR",,get_full_name());
      this.CMIUDDR.configure(this, null, "");
      this.CMIUDDR.build();
      this.default_map.add_reg(this.CMIUDDR, `UVM_REG_ADDR_WIDTH'hF0C, "RO", 0);
		this.CMIUDDR_DbgData = this.CMIUDDR.DbgData;
		this.DbgData = this.CMIUDDR.DbgData;
      this.CMIUCMCIDR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUCMCIDR::type_id::create("CMIUCMCIDR",,get_full_name());
      this.CMIUCMCIDR.configure(this, null, "");
      this.CMIUCMCIDR.build();
      this.default_map.add_reg(this.CMIUCMCIDR, `UVM_REG_ADDR_WIDTH'hFF8, "RO", 0);
		this.CMIUCMCIDR_NumSets = this.CMIUCMCIDR.NumSets;
		this.NumSets = this.CMIUCMCIDR.NumSets;
		this.CMIUCMCIDR_NumWays = this.CMIUCMCIDR.NumWays;
		this.NumWays = this.CMIUCMCIDR.NumWays;
		this.CMIUCMCIDR_Type = this.CMIUCMCIDR.Type;
		this.Type = this.CMIUCMCIDR.Type;
		this.CMIUCMCIDR_rsvd1 = this.CMIUCMCIDR.rsvd1;
      this.CMIUIDR = ral_reg_concerto_registers_Coherent_Memory_Interface_Unit_CMIUIDR::type_id::create("CMIUIDR",,get_full_name());
      this.CMIUIDR.configure(this, null, "");
      this.CMIUIDR.build();
      this.default_map.add_reg(this.CMIUIDR, `UVM_REG_ADDR_WIDTH'hFFC, "RO", 0);
		this.CMIUIDR_ImplVer = this.CMIUIDR.ImplVer;
		this.ImplVer = this.CMIUIDR.ImplVer;
		this.CMIUIDR_CmiId = this.CMIUIDR.CmiId;
		this.CmiId = this.CMIUIDR.CmiId;
		this.CMIUIDR_HntCap = this.CMIUIDR.HntCap;
		this.HntCap = this.CMIUIDR.HntCap;
		this.CMIUIDR_Cmc = this.CMIUIDR.Cmc;
		this.Cmc = this.CMIUIDR.Cmc;
		this.CMIUIDR_rsvd1 = this.CMIUIDR.rsvd1;
   endfunction : build

	`uvm_object_utils(ral_block_concerto_registers_Coherent_Memory_Interface_Unit)

endclass : ral_block_concerto_registers_Coherent_Memory_Interface_Unit



`endif
