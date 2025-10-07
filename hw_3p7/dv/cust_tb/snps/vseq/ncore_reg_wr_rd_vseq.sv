class wr_rd_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

  uvm_reg rg;
  `uvm_object_utils(wr_rd_seq)
  
  function new(string name="wr_rd_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    uvm_reg_field fields[$];
    string mode[`UVM_REG_DATA_WIDTH];
    uvm_reg_map maps[$];
    uvm_reg_data_t  dc_mask;
    uvm_reg_data_t  reset_val;
    int n_bits;
    string field_access;
    uvm_status_e status;
    uvm_reg_data_t  val, exp, v;
    bit bit_val;
    
    if(rg == null) begin
      `uvm_error ("wr_rd_seq", "No register specified to run sequence on");
      return;
    end
    
    if(uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},"NO_REG_TESTS", 0) != null || uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},"NO_REG_BIT_BASH_TEST", 0) != null )
    return;
    
    n_bits = rg.get_n_bytes() * 8;
    rg.get_fields(fields);
    rg.get_maps(maps);
     
    foreach (maps[j]) begin
      uvm_status_e status;
      uvm_reg_data_t  val, exp, v,read_data;
      int next_lsb;
      next_lsb = 0;
      dc_mask  = 0;
      
      foreach (fields[k]) begin
        int lsb, w, dc;
        field_access = fields[k].get_access(maps[j]);
        dc  = (fields[k].get_compare() == UVM_NO_CHECK);
        lsb = fields[k].get_lsb_pos();
        w   = fields[k].get_n_bits();
        // Ignore Write-only fields because you are not supposed to read them
        case (field_access)
            "WO", "WOC", "WOS", "WO1", "NOACCESS": dc = 1;
        endcase
            // Any unused bits on the right side of the LSB?
        while (next_lsb < lsb) mode[next_lsb++] = "RO";
        
        repeat (w) begin
          mode[next_lsb] = field_access;
          dc_mask[next_lsb] = dc;
          next_lsb++;
        end
      end
      // Any unused bits on the left side of the MSB?
      while (next_lsb < `UVM_REG_DATA_WIDTH)
        mode[next_lsb++] = "RO";      
        bash_reg(rg,maps[j], dc_mask);
    end
  endtask: body
  
  task bash_reg (uvm_reg rg, uvm_reg_map map, uvm_reg_data_t dc_mask);
    uvm_status_e status;
    uvm_reg_data_t  val, exp, v;
    bit bit_val;
    
    `uvm_info("wr_rd_seq", $sformatf("...Bashing reg %0s", rg.get_full_name()),UVM_NONE);
    
       for(int i=0;i<3;i++)begin  
         val=32'h55555555;
         if(i==1)val[31:0] = ~val;
         if(i==2)val[31:0] = 0;
         v = val;
         rg.write(status, val);
         if (status != UVM_IS_OK)
             `uvm_error("wr_rd_seq", $sformatf("Status was %s when writing to register \"%s\" through map \"%s\".",status.name(), rg.get_full_name(), map.get_full_name()));
         exp = rg.get() & ~dc_mask;
         rg.read(status, val);
         if (status != UVM_IS_OK)
             `uvm_error("wr_rd_seq", $sformatf("Status was %s when reading register \"%s\" through map \"%s\".",status.name(), rg.get_full_name(), map.get_full_name()));
         val &= ~dc_mask;
         if (val !== exp) 
             `uvm_error("wr_rd_seq", $sformatf("Writing a %0h in  of register \"%s\" with initial value 'h%h yielded 'h%h instead of 'h%h",v, rg.get_full_name(), v, val, exp));
       end
  endtask: bash_reg
endclass: wr_rd_seq

class reg_wr_rd_seq extends uvm_reg_sequence#(uvm_sequence #(uvm_reg_item));

  `uvm_object_utils(reg_wr_rd_seq)
  wr_rd_seq reg_seq;
  
  function new(string name="reg_wr_rd_seq");
      super.new(name);
  endfunction : new
  
  virtual task body();
    ral_sys_ncore model;
    uvm_status_e status;
    bit[31:0] data,write_data,expt_data;
    bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
    uvm_reg_field 	fields[$];
    string str;
    int lsb,bits;
    $cast(model, this.model);
    
    if (model == null) begin
      `uvm_error("reg_wr_rd_seq", "No register model specified to run sequence on");
       return;
    end
    reg_seq = wr_rd_seq::type_id::create("reg_seq");
    uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_NONE);
    model.reset();
    do_block(model);
  endtask 
  
  task do_block(uvm_reg_block blk);
    uvm_reg regs[$];
    if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},"NO_REG_TESTS", 0) != null || uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},"NO_REG_BIT_BASH_TEST", 0) != null )
    return;
    // Iterate over all registers, checking accesses
    blk.get_registers(regs, UVM_NO_HIER);
    foreach (regs[i]) begin
      // Registers with some attributes are not to be tested
      if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},"NO_REG_TESTS", 0) != null || uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},"NO_REG_BIT_BASH_TEST", 0) != null )
      continue;
      reg_seq.rg = regs[i];
      reg_seq.start(null);
    end
    
    begin
      uvm_reg_block blks[$];
      blk.get_blocks(blks);
      foreach (blks[i]) begin
        do_block(blks[i]);
      end
    end
  endtask: do_block
endclass: reg_wr_rd_seq


