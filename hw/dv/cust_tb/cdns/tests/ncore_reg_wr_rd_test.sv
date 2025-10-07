
//--------------------------------------------------------
// Test : ncore_reg_wr_rd_test
//---------------------------------------------------------
//#Stimulus.Cust_tb.reg_wr_rd

class ncore_reg_wr_rd_test extends ncore_sys_test;

   // UVM Component Utility macro
  `uvm_component_utils(ncore_reg_wr_rd_test);

  //Bit bash sequence 
  reg_wr_rd_seq   csr_seq;

  function new (string name="ncore_reg_wr_rd_test", uvm_component parent);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("ncore_reg_wr_rd_test", "is entered", UVM_LOW)

    // Create the sequence class
    csr_seq = reg_wr_rd_seq::type_id::create("csr_seq");

    `uvm_info("ncore_reg_wr_rd_test", "build - is exited", UVM_LOW)

  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info("run_phase", "Entered...", UVM_LOW)

    <%var largest_index = (obj.nDCEs > obj.nDMIs) ? ( (obj.nDCEs > obj.nDIIs) ? obj.nDCEs : obj.nDIIs ) : ( (obj.nDMIs > obj.nDIIs) ? obj.nDMIs : obj.nDIIs );%>
    csr_seq = reg_wr_rd_seq::type_id::create("csr_seq");
    csr_seq.model = env.regmodel;

<% for(var idx = 0; idx < obj.nAIUs; idx++) { 
     if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) {%>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.NRSBAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.NRSBHR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.NRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(var j=0;j<largest_index;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this); // To be rechecked
    <%} %>

    <%} else {

     for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>

    //AE to be rechecked
    <%for(var pidx = 0; pidx < 8; ++pidx){
     if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUEDR<%=pidx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} else { %>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUEDR<%=pidx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%}}%>
    <% if (obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && obj.AiuInfo[idx].useCache == 1){
     if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} else { %>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%}} %>
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
   // uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUQOSSR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(var j=0;j<largest_index;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} %>
    <%} else { %>
   // uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUQOSSR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(var j=0;j<largest_index;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} %>
    <%}}}%>
<%}%>

    <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    //uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUSER0.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUSFMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(var j=0;j<obj.nDMIs;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <% } %>
    <% } %>


    <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
       <% if(obj.DmiInfo[pidx].useCmc) { %>
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
      <% } %>
    <% } %>
    

    uvm_resource_db#(bit)::set({"REG::", env.regmodel.sys_dii.DIIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);

    <% for(var idx = 0; idx < (obj.DveInfo[0].nAius / 32) ;idx++) {%>
        uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVEUSER<%=idx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this); //dve_ral_test.svh
        uvm_resource_db#(bit)::set({"REG::", env.regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVEMCNTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <% } %>


    // Run the reg model sequence
    phase.raise_objection(this);
    
    csr_seq.start(null);
    env.regmodel.print();
    phase.drop_objection(this);
  endtask : run_phase
endclass

