<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var ridx = 0;
   var chiaiu_idx = 0;
   var axiaiu_idx = 0;
   var aceaiu_idx = 0;
   var aceliteeaiu_idx = 0;
   var ioaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var nGPRA = 0;
   var nDII = 0;
   var nDMI = 0;
   var nAXI = 0;
   var nACE = 0;
   var nACELITE = 0;
   var nCHI = 0;
   var nINIT = 0;
   var nAIU = 0;
   var cnt_multi = 200*(obj.AiuInfo.length+obj.DceInfo.length+obj.DmiInfo.length+obj.DveInfo.length+obj.DiiInfo.length); 


   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')) {
         axiaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       } else if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')){
         aceliteeaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       } else if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')){
         aceaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
   }
   nINIT = chiaiu_idx + ioaiu_idx;

   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
   nGPRA = obj.AiuInfo[0].nGPRA;
   nDII = obj.nDIIs;
   nDMI = obj.nDMIs;
   nACE = 0;
   nAIU = obj.nAIUs;
%>
<% if(obj.useResiliency == 1){ %>
//--------------------------------------------------------
// Test : ncore_fsc_Uncorr_Error_test 
//---------------------------------------------------------
class ncore_fsc_Uncorr_Error_test extends ncore_base_test;

   // UVM Component Utility macro
  `uvm_component_utils(ncore_fsc_Uncorr_Error_test);
  
   bit[31:0]  read_data,temp_read_data;
   bit[31:0]  write_data;
   bit [31:0] fsc_loop_cnt;
   bit bist_seq_automatic_manual;  
   uvm_status_e   status;
   uvm_object objectors_list[$];
   uvm_objection objection;
   uvm_event mission_fault_detected;
   int cnt;

   virtual cdnApb4Interface #(.NUM_OF_SLAVES(1),
                     .ADDRESS_WIDTH(12),
                     .DATA_WIDTH(32)) m_fsc_apb_if;
  function new (string name="ncore_fsc_Uncorr_Error_test", uvm_component parent);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("ncore_fsc_Uncorr_Error_test", "is entered", UVM_NONE)
     if(!uvm_config_db #(virtual cdnApb4Interface #(
                     .NUM_OF_SLAVES(1),
                     .ADDRESS_WIDTH(12),
                     .DATA_WIDTH(32)))::get(null,"","apb_if", m_fsc_apb_if))begin
          `uvm_error("Fsc test", "virtual if is not found")
      end


    mission_fault_detected = new("mission_fault_detected");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "mission_fault_detected" ),
                                    .value( mission_fault_detected ))) begin
       `uvm_error("Fsc test", "Event mission_fault_detected is not found")
    end
    if (!uvm_config_db#(bit [31:0])::get(this,"","fsc_loop_cnt",fsc_loop_cnt)) begin
       `uvm_error("Fsc test", "fsc_loop_cnt  not found")
    end
    `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("fsc_loop_cnt %0d \n",fsc_loop_cnt),UVM_NONE);

    `uvm_info("ncore_fsc_Uncorr_Error_test", "build - is exited", UVM_NONE)

  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    int num_clk;
    super.run_phase(phase);
    `uvm_info("run_phase", "Entered...", UVM_NONE)
    phase.raise_objection(this);
    `uvm_info("ncore_fsc_Uncorr_Error_test", "Starting FSC uncorr sequence",UVM_NONE)
      fork
          begin
              `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("IN_REPEAT_B4_TRIGGER at time %t \n",$time),UVM_NONE);
              repeat(fsc_loop_cnt) begin
                  `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("Waiting  mission_fault_detected triggered fsc_loop_cnt :%0d",fsc_loop_cnt), UVM_NONE);
                  mission_fault_detected.wait_trigger();
                  `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("Event mission_fault_detected triggered"), UVM_NONE);
                    bist_seq_automatic_manual =  $urandom_range(0,1); // Deciding if start automatic bist seq or manual
                  if(bist_seq_automatic_manual) begin //Manual Bist Seq
                      write_data = 'h1;
                     `uvm_info("ncore_fsc_Uncorr_Error_test", "Writing 1st location of FSCBISTCR to start manual Bist seq.",UVM_NONE)
                     repeat(6) begin  
                         env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                         `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("step:%0d apb_clk: %0d at time : %t\n",cnt,m_fsc_apb_if.clk,$time),UVM_NONE)
                         do begin
                           temp_read_data=0;
			               env.resiliency_m_regs.fsc.FSCBISTAR.read(status,temp_read_data);
                         end while(temp_read_data[cnt] !=1);
                         cnt++;
                     end
                     cnt = 0 ; 
                  end
                  else begin //Automatic Bist Seq  
                      write_data = 'h2;
                      env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                      `uvm_info("ncore_fsc_Uncorr_Error_test", "Writing 1th location of FSCBISTCR to set  automatic Bist seq.",UVM_NONE)
                      write_data = 'h3;
                      env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                      `uvm_info("ncore_fsc_Uncorr_Error_test", "Written 0th location of FSCBISTCR to start automatic Bist seq.",UVM_NONE)
                      repeat(16500)  @(posedge m_fsc_apb_if.clk); 
                  end
                  `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("apb_clk: %0d at time : %t\n",m_fsc_apb_if.clk,$time),UVM_NONE)
                  repeat(100)  @(posedge m_fsc_apb_if.clk); 
                  `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("apb_clk: %0d at time : %t\n",m_fsc_apb_if.clk,$time),UVM_NONE)
                  read_data=0;
                  env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
                  `uvm_info("ncore_fsc_Uncorr_Error_test",$sformatf("SCBISTAR read data %0h",read_data),UVM_NONE);
                  if(read_data[11:6] != 0) begin 
                      `uvm_error("ncore_fsc_Uncorr_Error_test",$sformatf("Error detected in Bist seq, SCBISTAR Reg %0h",read_data[9:5]))
                  end
                  if(read_data[5:0] != 'h3F) begin
                      `uvm_error("ncore_fsc_Uncorr_Error_test",$sformatf("Something went wrong in Bist seq, SCBISTAR Reg %0h",read_data[4:0]))
                  end
                 end
                 `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("%0d times checked the BIST CSR flow, now exiting...",fsc_loop_cnt), UVM_NONE)
                 // Fetching the objection from current phase
                 objection = phase.get_objection();
                 // Collecting all the objectors which currently have objections raised
                 objection.get_objectors(objectors_list);
                 // Dropping the objections forcefully
                 foreach(objectors_list[i]) begin
                   `uvm_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM)
                   while(objection.get_objection_count(objectors_list[i]) != 0) begin
                     phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
                   end
                 end
                 `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("Jumping to report_phase"), UVM_NONE)
                 phase.jump(uvm_report_phase::get());
          end
      join

  endtask : run_phase
endclass : ncore_fsc_Uncorr_Error_test
<% } %>
