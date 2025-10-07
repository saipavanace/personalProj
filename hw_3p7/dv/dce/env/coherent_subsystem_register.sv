`ifndef RAL_COHERENT_SUBSYSTEM
`define RAL_COHERENT_SUBSYSTEM

//Auto generated system reg map

import uvm_pkg::*;

<%
var cfgDvm = []; //0 ACE-lite 1 ACE
var enDvm = false;
obj.AiuInfo.forEach(function(bundle, indx) {
    if(bundle.NativeInfo.DvmInfo.nDvmCmpInFlight) {
        enDvm = true;
    }
});

obj.AiuInfo.forEach(function(bundle, indx) {
    if(enDvm) {
         cfgDvm.push(1);
    } else {
         cfgDvm.push(0);
    }
});

var cfgSfType = []
obj.SnoopFilterInfo.forEach(function(bundle, indx) {
    var tmpObj = {
        "numSets": 0,
        "numWays": 0,
        "sfType": 1
    };

    if(bundle.fnFilterType === "TAGFILTER") {

        tmpObj.numSets = (bundle.StorageInfo.nSets - 1);
        tmpObj.numWays = (bundle.StorageInfo.nWays - 1);
        if(bundle.StorageInfo.nVictimEntries) {
              if(bundle.StorageInfo.fnTagFilterType === "EXPLICITOWNER") {
                  tmpObj.sfType = 7;
              } else if(bundle.StorageInfo.fnTagFilterType === "PRESENCEVECTOR") {
                  tmpObj.sfType = 6;
              }
        } else {
              if(bundle.StorageInfo.fnTagFilterType === "EXPLICITOWNER") {
                  tmpObj.sfType = 3;
              } else if(bundle.StorageInfo.fnTagFilterType === "PRESENCEVECTOR") {
                  tmpObj.sfType = 2;
              }
        }
    }
    cfgSfType.push(tmpObj);
});

%>

class ral_reg_concerto_registers_Coherent_Subsystem_CSADSER0 extends uvm_reg;
<% cfgDvm.forEach(function(bundle, indx) { %>
	rand uvm_reg_field DvmSnpEn<%=indx%>;
<% }); %>
        rand uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSER0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
<% cfgDvm.forEach(function(bundle, indx) {
     if(bundle) { %>
      this.DvmSnpEn<%=indx%> = uvm_reg_field::type_id::create("DvmSnpEn<%=indx%>",,get_full_name());
      this.DvmSnpEn<%=indx%>.configure(this, 1, <%=indx%>, "RW", 0, 1'h0, 1, 0, 0);
<%   } else { %>
      this.DvmSnpEn<%=indx%> = uvm_reg_field::type_id::create("DvmSnpEn<%=indx%>",,get_full_name());
      this.DvmSnpEn<%=indx%>.configure(this, 1, <%=indx%>, "RO", 0, 1'h0, 1, 0, 0);
<%   } %>
<% }); %>
      
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, <%=32 - cfgDvm.length%>, <%=cfgDvm.length%>, "RO", 0, <%=cfgDvm.length%>'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSER0)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSER0


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSER1 extends uvm_reg;
	rand uvm_reg_field DvmSnpEn;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSER1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpEn = uvm_reg_field::type_id::create("DvmSnpEn",,get_full_name());
      this.DvmSnpEn.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSER1)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSER1


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSER2 extends uvm_reg;
	rand uvm_reg_field DvmSnpEn;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSER2");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpEn = uvm_reg_field::type_id::create("DvmSnpEn",,get_full_name());
      this.DvmSnpEn.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSER2)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSER2


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSER3 extends uvm_reg;
	rand uvm_reg_field DvmSnpEn;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSER3");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpEn = uvm_reg_field::type_id::create("DvmSnpEn",,get_full_name());
      this.DvmSnpEn.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSER3)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSER3


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR0 extends uvm_reg;
	uvm_reg_field DvmSnpActv;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSAR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpActv = uvm_reg_field::type_id::create("DvmSnpActv",,get_full_name());
      this.DvmSnpActv.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR0)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR0


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR1 extends uvm_reg;
	uvm_reg_field DvmSnpActv;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSAR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpActv = uvm_reg_field::type_id::create("DvmSnpActv",,get_full_name());
      this.DvmSnpActv.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR1)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR1


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR2 extends uvm_reg;
	uvm_reg_field DvmSnpActv;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSAR2");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpActv = uvm_reg_field::type_id::create("DvmSnpActv",,get_full_name());
      this.DvmSnpActv.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR2)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR2


class ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR3 extends uvm_reg;
	uvm_reg_field DvmSnpActv;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSADSAR3");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.DvmSnpActv = uvm_reg_field::type_id::create("DvmSnpActv",,get_full_name());
      this.DvmSnpActv.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR3)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR3


class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR0 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR0)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR0

class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR1 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR1)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR1

class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR2 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR2");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR2)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR2

class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR3 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR3");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR3)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR3

class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR4 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR4");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR4)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR4

class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR5 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR5");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR5)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR5

class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR6 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR6");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR6)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR6

class ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR7 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSCEISR7");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR7)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR7

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR0 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR0");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR0)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR0

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR1 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR1");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR1)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR1

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR2 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR2");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR2)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR2

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR3 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR3");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR3)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR3

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR4 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR4");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR4)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR4

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR5 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR5");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR5)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR5

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR6 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR6");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR6)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR6

class ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR7 extends uvm_reg;
	uvm_reg_field ErrIntVld;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUEISR7");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ErrIntVld = uvm_reg_field::type_id::create("ErrIntVld",,get_full_name());
      this.ErrIntVld.configure(this, 32, 0, "RO", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR7)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR7

<% cfgSfType.forEach(function(bundle, indx) { %>
class ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR<%=indx%> extends uvm_reg;
	uvm_reg_field NumSets;
	uvm_reg_field NumWays;
	uvm_reg_field Type;
	uvm_reg_field Rsvd1;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSSFIDR<%=indx%>");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.NumSets = uvm_reg_field::type_id::create("NumSets",,get_full_name());
      this.NumSets.configure(this, 20, 0, "RO", 0, 20'd<%=bundle.numSets%>, 1, 0, 0);
      this.NumWays = uvm_reg_field::type_id::create("NumWays",,get_full_name());
      this.NumWays.configure(this, 6, 20, "RO", 0, 6'd<%=bundle.numWays%>, 1, 0, 0);
      this.Type = uvm_reg_field::type_id::create("Type",,get_full_name());
      this.Type.configure(this, 3, 26, "RO", 0, 3'd<%=bundle.sfType%>, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 3, 29, "RO", 0, 3'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR<%=indx%>)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR<%=indx%>
<% }); %>

class ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR extends uvm_reg;
	uvm_reg_field NumCaius;
	uvm_reg_field Rsvd1;
	uvm_reg_field NumNcbus;
	uvm_reg_field Rsvd2;
	uvm_reg_field NumDirus;
	uvm_reg_field Rsvd3;
	uvm_reg_field NumCmius;
	uvm_reg_field Rsvd4;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSUIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.NumCaius = uvm_reg_field::type_id::create("NumCaius",,get_full_name());
      this.NumCaius.configure(this, 7, 0, "RO", 0, 7'd<%=obj.AiuInfo.length%>, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 1, 7, "RO", 0, 1'h0, 1, 0, 0);
      this.NumNcbus = uvm_reg_field::type_id::create("NumNcbus",,get_full_name());
      this.NumNcbus.configure(this, 6, 8, "RO", 0, 6'd<%=obj.BridgeAiuInfo.length%>, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 2, 14, "RO", 0, 2'h0, 1, 0, 0);
      this.NumDirus = uvm_reg_field::type_id::create("NumDirus",,get_full_name());
      this.NumDirus.configure(this, 6, 16, "RO", 0, 6'd<%=obj.DceInfo.nDces%>, 1, 0, 0);
      this.Rsvd3 = uvm_reg_field::type_id::create("Rsvd3",,get_full_name());
      this.Rsvd3.configure(this, 2, 22, "RO", 0, 2'h0, 1, 0, 0);
      this.NumCmius = uvm_reg_field::type_id::create("NumCmius",,get_full_name());
      this.NumCmius.configure(this, 6, 24, "RO", 0, 6'd<%=obj.DmiInfo.length%>, 1, 0, 0);
      this.Rsvd4 = uvm_reg_field::type_id::create("Rsvd4",,get_full_name());
      this.Rsvd4.configure(this, 2, 30, "RO", 0, 2'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR


class ral_reg_concerto_registers_Coherent_Subsystem_CSIDR extends uvm_reg;
	uvm_reg_field RelVer;
	uvm_reg_field DirClOffset;
	uvm_reg_field Rsvd1;
	uvm_reg_field NumSfs;
	uvm_reg_field Rsvd2;

	function new(string name = "concerto_registers_Coherent_Subsystem_CSIDR");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.RelVer = uvm_reg_field::type_id::create("RelVer",,get_full_name());
      this.RelVer.configure(this, 8, 0, "RO", 0, 8'd9, 1, 0, 1);
      this.DirClOffset = uvm_reg_field::type_id::create("DirClOffset",,get_full_name());
      this.DirClOffset.configure(this, 3, 8, "RO", 0, 3'h1, 1, 0, 0);
      this.Rsvd1 = uvm_reg_field::type_id::create("Rsvd1",,get_full_name());
      this.Rsvd1.configure(this, 7, 11, "RO", 0, 7'h0, 1, 0, 0);
      this.NumSfs = uvm_reg_field::type_id::create("NumSfs",,get_full_name());
      this.NumSfs.configure(this, 5, 18, "RO", 0, 5'h<%=obj.SnoopFilterInfo.length - 1%>, 1, 0, 0);
      this.Rsvd2 = uvm_reg_field::type_id::create("Rsvd2",,get_full_name());
      this.Rsvd2.configure(this, 9, 23, "RO", 0, 9'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_concerto_registers_Coherent_Subsystem_CSIDR)

endclass : ral_reg_concerto_registers_Coherent_Subsystem_CSIDR


class ral_block_concerto_registers_Coherent_Subsystem extends uvm_reg_block;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSER0 CSADSER0;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSER1 CSADSER1;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSER2 CSADSER2;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSER3 CSADSER3;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR0 CSADSAR0;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR1 CSADSAR1;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR2 CSADSAR2;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR3 CSADSAR3;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR0 CSCEISR0;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR1 CSCEISR1;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR2 CSCEISR2;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR3 CSCEISR3;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR4 CSCEISR4;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR5 CSCEISR5;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR6 CSCEISR6;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR7 CSCEISR7;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR0 CSUEISR0;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR1 CSUEISR1;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR2 CSUEISR2;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR3 CSUEISR3;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR4 CSUEISR4;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR5 CSUEISR5;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR6 CSUEISR6;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR7 CSUEISR7;
<% cfgSfType.forEach(function(bundle, indx) { %>
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR<%=indx%> CSSFIDR<%=indx%>;
<% }); %>
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR CSUIDR;
	rand ral_reg_concerto_registers_Coherent_Subsystem_CSIDR CSIDR;
<% cfgDvm.forEach(function(bundle, indx) { %>
	rand uvm_reg_field CSADSER0_DvmSnpEn<%=indx%>;
<% }); %>
	rand uvm_reg_field CSADSER1_DvmSnpEn;
	rand uvm_reg_field CSADSER2_DvmSnpEn;
	rand uvm_reg_field CSADSER3_DvmSnpEn;
	uvm_reg_field CSADSAR0_DvmSnpActv;
	uvm_reg_field CSADSAR1_DvmSnpActv;
	uvm_reg_field CSADSAR2_DvmSnpActv;
	uvm_reg_field CSADSAR3_DvmSnpActv;
	uvm_reg_field CSCEISR0_ErrIntVld;
	uvm_reg_field CSCEISR1_ErrIntVld;
	uvm_reg_field CSCEISR2_ErrIntVld;
	uvm_reg_field CSCEISR3_ErrIntVld;
	uvm_reg_field CSCEISR4_ErrIntVld;
	uvm_reg_field CSCEISR5_ErrIntVld;
	uvm_reg_field CSCEISR6_ErrIntVld;
	uvm_reg_field CSCEISR7_ErrIntVld;
	uvm_reg_field CSUEISR0_ErrIntVld;
	uvm_reg_field CSUEISR1_ErrIntVld;
	uvm_reg_field CSUEISR2_ErrIntVld;
	uvm_reg_field CSUEISR3_ErrIntVld;
	uvm_reg_field CSUEISR4_ErrIntVld;
	uvm_reg_field CSUEISR5_ErrIntVld;
	uvm_reg_field CSUEISR6_ErrIntVld;
	uvm_reg_field CSUEISR7_ErrIntVld;
<% cfgSfType.forEach(function(bundle, indx) { %>
	uvm_reg_field CSSFIDR<%=indx%>_NumSets;
	uvm_reg_field NumSets<%=indx%>;
	uvm_reg_field CSSFIDR<%=indx%>_NumWays;
	uvm_reg_field NumWays<%=indx%>;
	uvm_reg_field CSSFIDR<%=indx%>_Type;
	uvm_reg_field Type<%=indx%>;
	uvm_reg_field CSSFIDR<%=indx%>_Rsvd1;
<% }); %>
	uvm_reg_field CSUIDR_NumCaius;
	uvm_reg_field NumCaius;
	uvm_reg_field CSUIDR_Rsvd1;
	uvm_reg_field CSUIDR_NumNcbus;
	uvm_reg_field NumNcbus;
	uvm_reg_field CSUIDR_Rsvd2;
	uvm_reg_field CSUIDR_NumDirus;
	uvm_reg_field NumDirus;
	uvm_reg_field CSUIDR_Rsvd3;
	uvm_reg_field Rsvd3;
	uvm_reg_field CSUIDR_NumCmius;
	uvm_reg_field NumCmius;
	uvm_reg_field CSUIDR_Rsvd4;
	uvm_reg_field Rsvd4;
	uvm_reg_field CSIDR_RelVer;
	uvm_reg_field RelVer;
	uvm_reg_field CSIDR_DirClOffset;
	uvm_reg_field DirClOffset;
	uvm_reg_field CSIDR_Rsvd1;
	uvm_reg_field CSIDR_NumSfs;
	uvm_reg_field NumSfs;
	uvm_reg_field CSIDR_Rsvd2;

	function new(string name = "concerto_registers_Coherent_Subsystem");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.CSADSER0 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSER0::type_id::create("CSADSER0",,get_full_name());
      this.CSADSER0.configure(this, null, "");
      this.CSADSER0.build();
      this.default_map.add_reg(this.CSADSER0, `UVM_REG_ADDR_WIDTH'h40, "RW", 0);
<% cfgDvm.forEach(function(bundle, indx) { %>
		this.CSADSER0_DvmSnpEn<%=indx%> = this.CSADSER0.DvmSnpEn<%=indx%>;
<% }); %>
      this.CSADSER1 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSER1::type_id::create("CSADSER1",,get_full_name());
      this.CSADSER1.configure(this, null, "");
      this.CSADSER1.build();
      this.default_map.add_reg(this.CSADSER1, `UVM_REG_ADDR_WIDTH'h44, "RW", 0);
		this.CSADSER1_DvmSnpEn = this.CSADSER1.DvmSnpEn;
      this.CSADSER2 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSER2::type_id::create("CSADSER2",,get_full_name());
      this.CSADSER2.configure(this, null, "");
      this.CSADSER2.build();
      this.default_map.add_reg(this.CSADSER2, `UVM_REG_ADDR_WIDTH'h48, "RW", 0);
		this.CSADSER2_DvmSnpEn = this.CSADSER2.DvmSnpEn;
      this.CSADSER3 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSER3::type_id::create("CSADSER3",,get_full_name());
      this.CSADSER3.configure(this, null, "");
      this.CSADSER3.build();
      this.default_map.add_reg(this.CSADSER3, `UVM_REG_ADDR_WIDTH'h4C, "RW", 0);
		this.CSADSER3_DvmSnpEn = this.CSADSER3.DvmSnpEn;
      this.CSADSAR0 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR0::type_id::create("CSADSAR0",,get_full_name());
      this.CSADSAR0.configure(this, null, "");
      this.CSADSAR0.build();
      this.default_map.add_reg(this.CSADSAR0, `UVM_REG_ADDR_WIDTH'h50, "RO", 0);
		this.CSADSAR0_DvmSnpActv = this.CSADSAR0.DvmSnpActv;
      this.CSADSAR1 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR1::type_id::create("CSADSAR1",,get_full_name());
      this.CSADSAR1.configure(this, null, "");
      this.CSADSAR1.build();
      this.default_map.add_reg(this.CSADSAR1, `UVM_REG_ADDR_WIDTH'h54, "RO", 0);
		this.CSADSAR1_DvmSnpActv = this.CSADSAR1.DvmSnpActv;
      this.CSADSAR2 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR2::type_id::create("CSADSAR2",,get_full_name());
      this.CSADSAR2.configure(this, null, "");
      this.CSADSAR2.build();
      this.default_map.add_reg(this.CSADSAR2, `UVM_REG_ADDR_WIDTH'h58, "RO", 0);
		this.CSADSAR2_DvmSnpActv = this.CSADSAR2.DvmSnpActv;
      this.CSADSAR3 = ral_reg_concerto_registers_Coherent_Subsystem_CSADSAR3::type_id::create("CSADSAR3",,get_full_name());
      this.CSADSAR3.configure(this, null, "");
      this.CSADSAR3.build();
      this.default_map.add_reg(this.CSADSAR3, `UVM_REG_ADDR_WIDTH'h5C, "RO", 0);
		this.CSADSAR3_DvmSnpActv = this.CSADSAR3.DvmSnpActv;
      this.CSCEISR0 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR0::type_id::create("CSCEISR0",,get_full_name());
      this.CSCEISR0.configure(this, null, "");
      this.CSCEISR0.build();
      this.default_map.add_reg(this.CSCEISR0, `UVM_REG_ADDR_WIDTH'h100, "RO", 0);
		this.CSCEISR0_ErrIntVld = this.CSCEISR0.ErrIntVld;
      this.CSCEISR1 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR1::type_id::create("CSCEISR1",,get_full_name());
      this.CSCEISR1.configure(this, null, "");
      this.CSCEISR1.build();
      this.default_map.add_reg(this.CSCEISR1, `UVM_REG_ADDR_WIDTH'h104, "RO", 0);
		this.CSCEISR1_ErrIntVld = this.CSCEISR1.ErrIntVld;
      this.CSCEISR2 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR2::type_id::create("CSCEISR2",,get_full_name());
      this.CSCEISR2.configure(this, null, "");
      this.CSCEISR2.build();
      this.default_map.add_reg(this.CSCEISR2, `UVM_REG_ADDR_WIDTH'h108, "RO", 0);
		this.CSCEISR2_ErrIntVld = this.CSCEISR2.ErrIntVld;
      this.CSCEISR3 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR3::type_id::create("CSCEISR3",,get_full_name());
      this.CSCEISR3.configure(this, null, "");
      this.CSCEISR3.build();
      this.default_map.add_reg(this.CSCEISR3, `UVM_REG_ADDR_WIDTH'h10C, "RO", 0);
		this.CSCEISR3_ErrIntVld = this.CSCEISR3.ErrIntVld;
      this.CSCEISR4 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR4::type_id::create("CSCEISR4",,get_full_name());
      this.CSCEISR4.configure(this, null, "");
      this.CSCEISR4.build();
      this.default_map.add_reg(this.CSCEISR4, `UVM_REG_ADDR_WIDTH'h110, "RO", 0);
		this.CSCEISR4_ErrIntVld = this.CSCEISR4.ErrIntVld;
      this.CSCEISR5 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR5::type_id::create("CSCEISR5",,get_full_name());
      this.CSCEISR5.configure(this, null, "");
      this.CSCEISR5.build();
      this.default_map.add_reg(this.CSCEISR5, `UVM_REG_ADDR_WIDTH'h114, "RO", 0);
		this.CSCEISR5_ErrIntVld = this.CSCEISR5.ErrIntVld;
      this.CSCEISR6 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR6::type_id::create("CSCEISR6",,get_full_name());
      this.CSCEISR6.configure(this, null, "");
      this.CSCEISR6.build();
      this.default_map.add_reg(this.CSCEISR6, `UVM_REG_ADDR_WIDTH'h118, "RO", 0);
		this.CSCEISR6_ErrIntVld = this.CSCEISR6.ErrIntVld;
      this.CSCEISR7 = ral_reg_concerto_registers_Coherent_Subsystem_CSCEISR7::type_id::create("CSCEISR7",,get_full_name());
      this.CSCEISR7.configure(this, null, "");
      this.CSCEISR7.build();
      this.default_map.add_reg(this.CSCEISR7, `UVM_REG_ADDR_WIDTH'h11C, "RO", 0);
		this.CSCEISR7_ErrIntVld = this.CSCEISR7.ErrIntVld;
      this.CSUEISR0 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR0::type_id::create("CSUEISR0",,get_full_name());
      this.CSUEISR0.configure(this, null, "");
      this.CSUEISR0.build();
      this.default_map.add_reg(this.CSUEISR0, `UVM_REG_ADDR_WIDTH'h140, "RO", 0);
		this.CSUEISR0_ErrIntVld = this.CSUEISR0.ErrIntVld;
      this.CSUEISR1 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR1::type_id::create("CSUEISR1",,get_full_name());
      this.CSUEISR1.configure(this, null, "");
      this.CSUEISR1.build();
      this.default_map.add_reg(this.CSUEISR1, `UVM_REG_ADDR_WIDTH'h144, "RO", 0);
		this.CSUEISR1_ErrIntVld = this.CSUEISR1.ErrIntVld;
      this.CSUEISR2 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR2::type_id::create("CSUEISR2",,get_full_name());
      this.CSUEISR2.configure(this, null, "");
      this.CSUEISR2.build();
      this.default_map.add_reg(this.CSUEISR2, `UVM_REG_ADDR_WIDTH'h148, "RO", 0);
		this.CSUEISR2_ErrIntVld = this.CSUEISR2.ErrIntVld;
      this.CSUEISR3 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR3::type_id::create("CSUEISR3",,get_full_name());
      this.CSUEISR3.configure(this, null, "");
      this.CSUEISR3.build();
      this.default_map.add_reg(this.CSUEISR3, `UVM_REG_ADDR_WIDTH'h14C, "RO", 0);
		this.CSUEISR3_ErrIntVld = this.CSUEISR3.ErrIntVld;
      this.CSUEISR4 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR4::type_id::create("CSUEISR4",,get_full_name());
      this.CSUEISR4.configure(this, null, "");
      this.CSUEISR4.build();
      this.default_map.add_reg(this.CSUEISR4, `UVM_REG_ADDR_WIDTH'h150, "RO", 0);
		this.CSUEISR4_ErrIntVld = this.CSUEISR4.ErrIntVld;
      this.CSUEISR5 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR5::type_id::create("CSUEISR5",,get_full_name());
      this.CSUEISR5.configure(this, null, "");
      this.CSUEISR5.build();
      this.default_map.add_reg(this.CSUEISR5, `UVM_REG_ADDR_WIDTH'h154, "RO", 0);
		this.CSUEISR5_ErrIntVld = this.CSUEISR5.ErrIntVld;
      this.CSUEISR6 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR6::type_id::create("CSUEISR6",,get_full_name());
      this.CSUEISR6.configure(this, null, "");
      this.CSUEISR6.build();
      this.default_map.add_reg(this.CSUEISR6, `UVM_REG_ADDR_WIDTH'h158, "RO", 0);
		this.CSUEISR6_ErrIntVld = this.CSUEISR6.ErrIntVld;
      this.CSUEISR7 = ral_reg_concerto_registers_Coherent_Subsystem_CSUEISR7::type_id::create("CSUEISR7",,get_full_name());
      this.CSUEISR7.configure(this, null, "");
      this.CSUEISR7.build();
      this.default_map.add_reg(this.CSUEISR7, `UVM_REG_ADDR_WIDTH'h15C, "RO", 0);
		this.CSUEISR7_ErrIntVld = this.CSUEISR7.ErrIntVld;
<% cfgSfType.forEach(function(bundle, indx) {
      var regAddr = 3840 + (4 * indx); %>
      this.CSSFIDR<%=indx%> = ral_reg_concerto_registers_Coherent_Subsystem_CSSFIDR<%=indx%>::type_id::create("CSSFIDR<%=indx%>",,get_full_name());
      this.CSSFIDR<%=indx%>.configure(this, null, "");
      this.CSSFIDR<%=indx%>.build();
      this.default_map.add_reg(this.CSSFIDR<%=indx%>, `UVM_REG_ADDR_WIDTH'd<%=regAddr%>, "RO", 0);
		this.CSSFIDR<%=indx%>_NumSets = this.CSSFIDR<%=indx%>.NumSets;
		this.NumSets<%=indx%> = this.CSSFIDR<%=indx%>.NumSets;
		this.CSSFIDR<%=indx%>_NumWays = this.CSSFIDR<%=indx%>.NumWays;
		this.NumWays<%=indx%> = this.CSSFIDR<%=indx%>.NumWays;
		this.CSSFIDR<%=indx%>_Type = this.CSSFIDR<%=indx%>.Type;
		this.Type<%=indx%> = this.CSSFIDR<%=indx%>.Type;
		this.CSSFIDR<%=indx%>_Rsvd1 = this.CSSFIDR<%=indx%>.Rsvd1;
<% }); %>
      this.CSUIDR = ral_reg_concerto_registers_Coherent_Subsystem_CSUIDR::type_id::create("CSUIDR",,get_full_name());
      this.CSUIDR.configure(this, null, "");
      this.CSUIDR.build();
      this.default_map.add_reg(this.CSUIDR, `UVM_REG_ADDR_WIDTH'hFF8, "RO", 0);
		this.CSUIDR_NumCaius = this.CSUIDR.NumCaius;
		this.NumCaius = this.CSUIDR.NumCaius;
		this.CSUIDR_Rsvd1 = this.CSUIDR.Rsvd1;
		this.CSUIDR_NumNcbus = this.CSUIDR.NumNcbus;
		this.NumNcbus = this.CSUIDR.NumNcbus;
		this.CSUIDR_Rsvd2 = this.CSUIDR.Rsvd2;
		this.CSUIDR_NumDirus = this.CSUIDR.NumDirus;
		this.NumDirus = this.CSUIDR.NumDirus;
		this.CSUIDR_Rsvd3 = this.CSUIDR.Rsvd3;
		this.Rsvd3 = this.CSUIDR.Rsvd3;
		this.CSUIDR_NumCmius = this.CSUIDR.NumCmius;
		this.NumCmius = this.CSUIDR.NumCmius;
		this.CSUIDR_Rsvd4 = this.CSUIDR.Rsvd4;
		this.Rsvd4 = this.CSUIDR.Rsvd4;
      this.CSIDR = ral_reg_concerto_registers_Coherent_Subsystem_CSIDR::type_id::create("CSIDR",,get_full_name());
      this.CSIDR.configure(this, null, "");
      this.CSIDR.build();
      this.default_map.add_reg(this.CSIDR, `UVM_REG_ADDR_WIDTH'hFFC, "RO", 0);
		this.CSIDR_RelVer = this.CSIDR.RelVer;
		this.RelVer = this.CSIDR.RelVer;
		this.CSIDR_DirClOffset = this.CSIDR.DirClOffset;
		this.DirClOffset = this.CSIDR.DirClOffset;
		this.CSIDR_Rsvd1 = this.CSIDR.Rsvd1;
		this.CSIDR_NumSfs = this.CSIDR.NumSfs;
		this.NumSfs = this.CSIDR.NumSfs;
		this.CSIDR_Rsvd2 = this.CSIDR.Rsvd2;
   endfunction : build

	`uvm_object_utils(ral_block_concerto_registers_Coherent_Subsystem)

endclass : ral_block_concerto_registers_Coherent_Subsystem



`endif
