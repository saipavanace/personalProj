//--------------------------------------------------------
// ncore_fsc_ralgen_err_intr_seq 
//---------------------------------------------------------
<%const chipletObj = obj.lib.getAllChipletRefs();%>
                                  
class ncore_fsc_ralgen_err_intr_seq extends uvm_reg_sequence;

  `uvm_object_utils(ncore_fsc_ralgen_err_intr_seq)
  
  uvm_event              reginit_done;
  uvm_status_e           status;
  uvm_reg_data_t         field_rd_data;
  uvm_reg_data_t         field_wr_data;
  uvm_reg                rg; 
  uvm_reg_field          fields;
  integer                ErrVld;
  
  <%for(pidx = 0; pidx < chipletObj[0].nAIUs; pidx++) {%>
      virtual ncore_irq_if m_irq_<%=chipletObj[0].AiuInfo[pidx].strRtlNamePrefix%>_if;
  <%}%>
  <%for(pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) {%>
      virtual ncore_irq_if m_irq_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_if;
  <%}%>
  <%for(pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) {%>
      virtual ncore_irq_if m_irq_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_if;
  <%}%>
  <%for(pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) {%>
      virtual ncore_irq_if m_irq_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_if;
  <%}%>
  <%for(pidx = 0; pidx < chipletObj[0].nDVEs; pidx++) {%>
      virtual ncore_irq_if m_irq_<%=chipletObj[0].DveInfo[pidx].strRtlNamePrefix%>_if;
  <%}%>
  
  ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
  
  function new (string name = "concerto_fullsys_ralgen_err_intr_seq");
    super.new(name);
  endfunction : new
  
  virtual task pre_body();
    string arg_value;
    super.pre_body();
    if (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
  endtask: pre_body
  
  virtual task post_body();
    super.post_body();
    if (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body
  
  virtual task body();
    ral_sys_ncore model;
    uvm_status_e status;
    time time_diff;
    bit[31:0] data;
    bit[<%=chipletObj[0].Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
    $cast(model, this.model);
  
    <%for(pidx = 0; pidx < chipletObj[0].nAIUs; pidx++) {%>
        if(!uvm_config_db#(virtual ncore_irq_if)::get(null,get_full_name(),"m_irq_<%=chipletObj[0].AiuInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=chipletObj[0].AiuInfo[pidx].strRtlNamePrefix%>_if))begin
          `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
        end
    <%}%>
    <%for(pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) {%>
        if(!uvm_config_db#(virtual ncore_irq_if)::get(null,get_full_name(),"m_irq_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_if))begin
          `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
        end
    <%}%>
    <%for(pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) {%>
        if(!uvm_config_db#(virtual ncore_irq_if)::get(null,get_full_name(),"m_irq_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_if))begin
          `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
        end
    <%}%>
    <%for(pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) {%>
        if(!uvm_config_db#(virtual ncore_irq_if)::get(null,get_full_name(),"m_irq_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_if))begin
          `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
        end
    <%}%>
    <%for(pidx = 0; pidx < chipletObj[0].nDVEs; pidx++) {%>
        if(!uvm_config_db#(virtual ncore_irq_if)::get(null,get_full_name(),"m_irq_<%=chipletObj[0].DveInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=chipletObj[0].DveInfo[pidx].strRtlNamePrefix%>_if))begin
          `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
        end
    <%}%>
  
    <%for(var idx = 0; idx < chipletObj[0].nAIUs; idx++) {
        if((chipletObj[0].AiuInfo[idx].fnNativeInterface == 'CHI-B')||(chipletObj[0].AiuInfo[idx].fnNativeInterface == 'CHI-E')) {%>
          ///step-1
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_1: check uncorrectable pin should be at reset state  at time: %t \n", $time),UVM_NONE)
          if(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
          end
  
          //step-2  
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_2: read register *UESR,it should be at reset state at time: %t \n",$time),UVM_NONE)
          model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
          addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();
          ErrVld = 0;
          if(field_rd_data[0] == ErrVld) begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
          end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
          end
  
          //step-3 set IntEn   
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_3: set ProtErrIntEn in UUEIR* at time: %t \n",$time),UVM_NONE)
          field_wr_data[0] = 1; 
          model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUEIR.write(status,field_wr_data,UVM_FRONTDOOR);
          addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUEIR.get_address();
   
          ///step-4
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_4: set *CESAR.ErrVld = 1 and ErrType = 0x2 (Native Interface Write Response Error) at time: %t \n",$time),UVM_NONE)
          ErrVld = 1;
          field_wr_data[0] = ErrVld; 
          field_wr_data[9:4] = 2;   
          model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESAR.write(status,field_wr_data,UVM_FRONTDOOR);
          addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESAR.get_address();
          field_wr_data[9:4] = 0;   
  
          ///step-5 check intr pin 
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_5: wait for uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
          wait(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 1)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt asserted"),UVM_NONE);
          end
   
          ///step-6
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_6: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
          model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
          addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();
  
          if(field_rd_data[0] == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
          end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
          end
  
          ///step-7 
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_7: set *UESR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
          ErrVld = 1;
          field_wr_data[0] = ErrVld; 
          model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.write(status,field_wr_data,UVM_FRONTDOOR);
          addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();
    
          ///step-8
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_8: wait for ucorrectable interrupt =0 at time: %t \n",$time),UVM_NONE)
          wait(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 0)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt de-asserted"),UVM_NONE);
          end
    
          ///step-9
          ErrVld = 0;
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_9: read *UESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
          model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
          addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();
          if(field_rd_data[0] == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h CAIUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
          end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h CAIUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
          end
  
        <%} else {
              for (var mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                ///step-1
                <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
                      if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                <%}else{%>
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
                      if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                <%}%>
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
                end
  
                //step-2  
                <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
                      model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
                      addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.get_address();
                <%} else { %>
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
                       model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
                       addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.get_address();
                <%}%>
                ErrVld = 0;
                if(field_rd_data[0] == ErrVld)begin
                  `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESAR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
                end else begin
                      `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
                end
  
              
                <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                     ///step-3
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_3: set *CESAR.ErrVld = 1 & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
                     ErrVld = 3;
                     field_wr_data = ErrVld; 
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
                     addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.get_address();
				     
                     ///step-4
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
                     addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.get_address();
  
                <%} else { %>
                      ///step-3
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR.ErrVld = 1 & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
                      ErrVld = 3;
                      field_wr_data = ErrVld; 
                      model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
                      addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.get_address();
				      
                      ///step-4
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
                      model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
                      addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.get_address();
                <%}%>
                if(field_rd_data == ErrVld)begin
                  `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b XAIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
                end else begin
                  `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b Expected :%b XAIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0] ,field_rd_data[1], field_wr_data[1]));
                end
  
              
                <%if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                    ///step-5
                    `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
                    if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                      `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
                    end
  
                    ///step-6
                    `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_6: read System interrupt register CAIUUESRx,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
                <%} else { %>
                      ///step-5
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
                      if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
                      end
  
                      ///step-6
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register CAIUUESRx,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
                      model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
                <%}%>
                if(!field_rd_data)begin
                  `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data),UVM_NONE)
                end
                else begin
                  `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data))
                end
  
                <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                     ///step-7 set IntEn
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCECR.ErrIntEn.set(1);
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCECR.update(status,UVM_FRONTDOOR);
                     addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCECR.get_address();
				     
                     ///step-8 check intr pin  
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
                     wait(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
                       `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c interrupt asserted"),UVM_NONE);
                     end
                     if(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
                       `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
                     end
				     
                     ///step-9 
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_9: read System interrupt register XAIUUESRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
                <%}else{ %>
  
                     ///step-7 set IntEn 
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCECR.ErrIntEn.set(1);
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCECR.update(status,UVM_FRONTDOOR);
                     addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCECR.get_address();
				     
                     ///step-8 check intr pin 
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
                     wait(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
                       `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
                     end
                     if(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
                       `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
                     end
				     
                     ///step-9 
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register XAIUUESRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
  
                <%}%>
                if(!field_rd_data)begin
                  `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data),UVM_MEDIUM)
                end
                else begin
                  `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data))
                end
                    
                <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                     ///step-10
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
                     ErrVld = 0;
                     field_wr_data = ErrVld; 
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
                     addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.get_address();
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
                     addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.get_address();
				     
                     ///step-11
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
              
                <%} else { %>
                      ///step-10
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
                      ErrVld = 0;
                      field_wr_data = ErrVld; 
                      model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
                      addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.get_address();
                      model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
                      addr = model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.get_address();
                      
                      ///step-11
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
                <%}%>
                if(field_rd_data == ErrVld)begin
                  `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b XAIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
                end else begin
                  `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b Expected :%b XAIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0] ,field_rd_data[1], field_wr_data[1]));
                end
  
                <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                     ///step-12
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
                     wait(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
                         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
                     end
                     if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
                     end 
				     
                     ///step-13
                     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_13: read System interrupt register XAIUUESR.,check to make sure all at time: %t \n",$time),UVM_NONE)
                     model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUUESR.read(status,field_rd_data,UVM_FRONTDOOR);
              
                <%} else { %>
                      ///step-12
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
                      wait(m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
                          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
                      end
                      if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
                      end
				      
                      ///step-13
                      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register XAIUUESR.,check to make sure all at time: %t \n",$time),UVM_NONE)
                      model.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUUESR.read(status,field_rd_data,UVM_FRONTDOOR);
                <%}%>
                if(!field_rd_data)begin
                  `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR. value :%b",field_rd_data),UVM_MEDIUM)
                end
                else begin
                  `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR. value :%b",field_rd_data))
                end
  
                <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                     if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                       `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
                     end
                <%} else { %>
                      if((m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
                      end
                 <%}%>
              <%}
        } %>
    <%}%>
    <%for(var idx = 0; idx < chipletObj[0].nDCEs; idx++){%>
        ///step-1
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
        if((m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
	    
        //step-2  
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.get_address();
        ErrVld = 0;
        if(field_rd_data[0] == ErrVld)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESAR_ErrVld value :%b ",addr,field_rd_data[0]), UVM_NONE)
        end else begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
        end
	    
        ///step-3
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR ErrVld = 1  & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
        ErrVld = 3;
        field_wr_data = ErrVld; 
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.get_address();
	    
        ///step-4
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR, check to make sure ErrVld = 1 & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.get_address();
        if(field_rd_data == ErrVld)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b & DCEUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
        end else begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b Expected :1 DCEUCESR_ErrCountOverflow value :%b Expected :1",addr,field_rd_data[0],field_rd_data[1]));
        end
	    
        ///step-5
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
        if((m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
	    
        ///step-6
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register DCEUUEIR,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
        if(!field_rd_data)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data),UVM_NONE)
        end
        else begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data))
        end
	    
        ///step-7 set IntEn
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCECR.ErrIntEn.set(1);
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCECR.update(status,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCECR.get_address();
	    
        ///step-8 check intr pin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
        wait(m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
        end
        if(m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
        end
	    
        ///step-9 
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register DCEUUEIRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
        if(!field_rd_data)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data),UVM_MEDIUM)
        end
        else begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data))
        end
        
        ///step-10
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
        ErrVld = 0;
        field_wr_data = ErrVld; 
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.get_address();
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.get_address();
	    
        ///step-11
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
        if(field_rd_data == ErrVld)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
        end else begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
        end
	    
        ///step-12
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
        wait(m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
        end
        if((m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
	    
        ///step-13
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register DCEUUEIR,check to make sure all at time: %t\n",$time),UVM_NONE)
        model.<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>.DCEUUEIR.read(status,field_rd_data,UVM_FRONTDOOR);
        if(!field_rd_data)begin
          `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR. value :%b",field_rd_data),UVM_MEDIUM)
        end
        else begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR. value :%b",field_rd_data))
        end
        if((m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
          `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
    <%}%>
    <%for(var idx = 0; idx < chipletObj[0].nDMIs; idx++){%>
        ///step-1
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
        if((m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
    
        //step-2  
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.get_address();
        ErrVld = 0;
        if(field_rd_data[0] == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESAR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
        end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
        end
    
        ///step-3
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR.ErrVld = 1 at time: %t \n",$time),UVM_NONE)
        ErrVld = 3;
        field_wr_data = ErrVld; 
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.get_address();
    
        ///step-4
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1  & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.get_address();
        if(field_rd_data == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value  :%b DMIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0], field_rd_data[1]), UVM_NONE)
        end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value :%b Expected :%b DMIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0], field_wr_data[0],field_rd_data[1], field_wr_data[1]));
        end
    
        ///step-5
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
        if((m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
    
        ///step-6
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register DMIUUEIR,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
        if(!field_rd_data)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data),UVM_NONE)
        end
        else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data))
        end
    
        ///step-7 set IntEn
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCECR.ErrIntEn.set(1);
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCECR.update(status,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCECR.get_address();
      
        /// step-8 check intr pin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
        wait(m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
        end
        if(m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
        end
    
        ///step-9 
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register DMIUUEIRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
        if(!field_rd_data)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data),UVM_MEDIUM)
        end
        else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data))
        end
        
        ///step-10
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
        ErrVld = 0;
        field_wr_data = ErrVld; 
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.get_address();
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.get_address();
    
        ///step-11
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
        if(field_rd_data == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value :%b DMIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
        end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value :%b Expected :%b DMIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0], field_rd_data[1], field_wr_data[1]));
        end
    
        ///step-12
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
        wait(m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
        end
        if((m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
    
        ///step-13
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register DMIUUEIR,check to make sure all at time: %t\n",$time),UVM_NONE)
        model.<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>.DMIUUEIR.read(status,field_rd_data,UVM_FRONTDOOR);
        if(!field_rd_data)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR. value :%b",field_rd_data),UVM_MEDIUM)
        end
        else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR. value :%b",field_rd_data))
        end
        if((m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
        end
    <%}%>
  
    <%for(var idx = 0; idx < chipletObj[0].nDIIs; idx++){%>
        <% if(chipletObj[0].DiiInfo[idx].useResiliency == 1 && chipletObj[0].DiiInfo[idx].ResilienceInfo.fnResiliencyProtectionType === "ecc"){ %>
            ///step-1
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
            if((m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
            end
    
            ///step-2  
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
            addr = model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.get_address();
            ErrVld = 0;
            if(field_rd_data[0] == ErrVld)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESAR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
            end else begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
            end
    
            ///step-3
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR.ErrVld = 1 at time: %t \n",$time),UVM_NONE)
            ErrVld = 3;
            field_wr_data = ErrVld; 
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
            addr = model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.get_address();
    
            ///step-4
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1  & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
            addr = model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.get_address();
            if(field_rd_data == ErrVld)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value  :%b DIIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0], field_rd_data[1]), UVM_NONE)
            end else begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value :%b Expected :%b DIIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0], field_rd_data[1], field_wr_data[1]));
            end
    
            ///step-5
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
            if((m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
            end
    
            ///step-6
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register DIIUUEIR,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
            if(!field_rd_data)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data),UVM_NONE)
            end
            else begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data))
            end
    
            /// set IntEn   step-7
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCECR.ErrIntEn.set(1);
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCECR.update(status,UVM_FRONTDOOR);
            addr = model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCECR.get_address();
    
            /// check intr pin  step-8 
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
            wait(m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
            end
            if(m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
            end
    
            //step-9 
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register DIIUUEIRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
            if(!field_rd_data)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data),UVM_MEDIUM)
            end
            else begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data))
            end
      
            //step-10
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
            ErrVld = 0;
            field_wr_data = ErrVld; 
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
            addr = model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.get_address();
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
            addr = model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.get_address();
    
            //step-11
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
            if(field_rd_data == ErrVld)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value :%b DIIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
            end else begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value :%b Expected :%b DIIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0], field_rd_data[1], field_wr_data[1]));
            end
    
            //step-12
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
            wait(m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
            end
            if((m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
            end
    
            //step-13
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register DIIUUEIR,check to make sure all at time: %t\n",$time),UVM_NONE)
            model.<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>.DIIUUEIR.read(status,field_rd_data,UVM_FRONTDOOR);
            if(!field_rd_data)begin
                `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR. value :%b",field_rd_data),UVM_MEDIUM)
            end
            else begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR. value :%b",field_rd_data))
            end
            if((m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=chipletObj[0].DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
                `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
            end
        <%}%>
    <%}%>
    <%for(var idx = 0; idx < chipletObj[0].nDVEs; idx++){%>
        ///step-1
        field_wr_data = 0; 
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_1: check uncorrectable pin should be at reset state  at time: %t \n", $time),UVM_NONE)
        if(m_irq_<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
        end
    
        //step-2  
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_2: read register *UESR,it should be at reset state at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();
        ErrVld = 0;
        if(field_rd_data[0] == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
        end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
        end
    
        /// step-3 set IntEn   
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_3: set MemErrIntEn in UUEIR* at time: %t \n",$time),UVM_NONE)
        field_wr_data[2] = 1; 
        model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUEIR.write(status,field_wr_data,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUEIR.get_address();
        field_wr_data = 0; 
     
        ///step-4
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_4: set *CESAR.ErrVld = 1 and ErrType = 0x2 (Native Interface Write Response Error) at time: %t \n",$time),UVM_NONE)
        ErrVld = 1;
        field_wr_data[0] = ErrVld; 
        model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESAR.write(status,field_wr_data,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESAR.get_address();
        field_wr_data[9:4] = 0;   
    
        ///step-5 check intr pin   
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_5: wait for uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
        wait(m_irq_<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 1)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt asserted"),UVM_NONE);
        end
     
        //step-6
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_6: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();
        if(field_rd_data[0] == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
        end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
        end
    
        //step-7 
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_7: set *UESR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
        ErrVld = 1;
        field_wr_data[0] = ErrVld; 
        model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.write(status,field_wr_data,UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();
      
        //step-8
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_8: wait for ucorrectable interrupt =0 at time: %t \n",$time),UVM_NONE)
        wait(m_irq_<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 0)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt de-asserted"),UVM_NONE);
        end
      
        //step-9
        ErrVld = 0;
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%> STEP_9: read *UESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
        model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
        addr = model.<%=chipletObj[0].DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();
        if(field_rd_data[0] == ErrVld)begin
            `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DVEUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
        end else begin
            `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DVEUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
        end
    <%}%>
  endtask: body

endclass: ncore_fsc_ralgen_err_intr_seq

