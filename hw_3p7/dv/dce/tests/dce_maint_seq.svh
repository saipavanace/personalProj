//***********************************************
// Maintenance Javascript Utility Functions
//***********************************************
   <% 
     var tag_filter_string = "";
     var filter_no = 0;
   
     obj.SnoopFilterInfo.forEach( function(snoop) {
	if(snoop.fnFilterType == "TAGFILTER") {
	  if(filter_no > 0)
	     tag_filter_string += ',';			       
	  tag_filter_string += filter_no;
	}				   
	filter_no++;					   
     });
   %>   


<% 
var sf_memWidth = [];
var filter_no = 0;
var nCacheIdsFromFilter = [];
var wCacheIdsFromFilter = [];
var nCacheIds = 0;
var memWidth = [];
for(var i=0; i<obj.SnoopFilterInfo.length; i++) {
    nCacheIdsFromFilter[i] = 0;
}
agentId = 0;

obj.AiuInfo.forEach( function(agent) {
    filterNum = agent.CmpInfo.idSnoopFilterSlice;
    if((agent.fnNativeInterface == "ACE") | (agent.useIoCache == 1)) {
	nCacheIdsFromFilter[filterNum] = nCacheIdsFromFilter[filterNum] + 1;
    }
    agentId++;
});
filter_no = 0
obj.SnoopFilterInfo.forEach( function(snoop) {
    var nCacheIdBits = 0;
    var log2_cache_ids;
    if (nCacheIdsFromFilter[filter_no] == 1) {
	nCacheIdBits = 1;
	log2_cache_ids;
    } else {
	nCacheIdBits = Math.ceil(Math.log2(nCacheIdsFromFilter[filter_no]));
	log2_cache_ids = Math.log2(nCacheIdsFromFilter[filter_no]);
    }


    if(snoop.fnFilterType == "TAGFILTER") {
	if(snoop.StorageInfo.fnTagFilterType == "EXPLICITOWNER") {
	    wCacheIdsFromFilter[filter_no] = Math.ceil(Math.log2(nCacheIdsFromFilter[filter_no] + 2));
	} else {
	    wCacheIdsFromFilter[filter_no] = nCacheIdBits;
	}
	var nTagBits = obj.DceInfo.Derived.wSfiAddr + obj.wSecurityAttribute - snoop.StorageInfo.SetSelectInfo.nSelectBits - obj.wCacheLineOffset;;

	if(snoop.StorageInfo.fnTagFilterType == "PRESENCEVECTOR") {
	    sf_memWidth[filter_no] = nTagBits + nCacheIdsFromFilter[filter_no];
	} else {
	    sf_memWidth[filter_no] = nTagBits + nCacheIdsFromFilter[filter_no] + wCacheIdsFromFilter[filter_no];
	}
    } else {
	 sf_memWidth[filter_no] = -1;
    }
    filter_no++;
}); 
var sf_memWidth_max = Math.max.apply(null, sf_memWidth);
sf_memWidth_max = Math.ceil(sf_memWidth_max / 32) * 32;

%>

<% var has_ocp = 0 %>
<% if(obj.BLK_SNPS_OCP_VIP) { has_ocp = 1 } %>		 
<%  if((obj.INHOUSE_OCP_VIP)) { 
        has_ocp = 1 %>
import ocp_agent_pkg::*;
<%  } %>

class dce_maint_seq extends uvm_sequence #(uvm_sequence_item);
   `uvm_object_utils(dce_maint_seq)
   <% if (obj.BLK_SNPS_OCP_VIP) { %>
  cust_svt_ocp_system_configuration test_cfg;

<% } %>
<%  if((obj.INHOUSE_OCP_VIP)) { %>
  ocp_agent_config       m_ocp_cfg;
  ocp_agent         m_ocp_agent;
<%  } %>
<% if(has_ocp) { %>
  dce_reg regs;
<% } %>
  bit [31:0] wr_data;
  bit [31:0] rd_data;
  bit [31:0] r_addr;
  bit [31:0] r_mask;
  bit [31:0] r_reset;
  string     reg_name;
  int lsb,msb;
  string Rsvd;
  int 	 wt_maint_recall_all,wt_maint_recall_addrs,wt_maint_recall_loc,wt_maint_recall_vb;
  int active_xact;
  CacheStateModel m_csm;
  int sf_memWidth[<%=obj.SnoopFilterInfo.length%>];
  int sf_memWidth_max = <%=sf_memWidth_max%>;

   
  function new(string name = "dce_maint_seq");
     super.new(name);
  <% var cur_filter_no = 0;
    sf_memWidth.forEach( function(snoop_width) { %>
	 sf_memWidth[<%=cur_filter_no%>] = <%=snoop_width%>;	 
  <% });%>
  regs = new();
  endfunction
  extern virtual task body;
  extern virtual task reg_rmwrite(string reg_name, bit [31:0] data);
  extern virtual task reg_wait_for_value(bit [31:0] data, string reg_name,output bit [31:0] rd_data);
  extern virtual task reg_read(string reg_name, output bit [31:0] rd_data, input int regnum = 0);
  extern virtual task reg_write(string reg_name, bit [31:0] data, input int regnum = 0);
  extern virtual function bit [31:0] mask_data(string name);
  extern virtual task maint_wait_inactive();
  extern virtual task maint_start_op(bit [3:0] opcode, bit[4:0] filter_no, <% if(obj.wSecurityAttribute > 1) {%> bit [<%=obj.wSecurityAttribute -1 %>:0] security_bits <% } else { %> bit security_bits <% } %> = 0);
  extern virtual task maint_write_loc(int index, int way, int word);
  extern virtual task maint_write_addr(longint addr);
  extern virtual task maint_write_entry(int index, int way, int filter_no, bit [<%=sf_memWidth_max - 1%>:0] data);
  extern virtual task maint_read_entry(int index, int way, int filter_no, output bit [<%=sf_memWidth_max - 1%>:0] data);
  extern virtual task maint_write_check_bits(int index, int way, int word, int filter_no, longint data);
  extern virtual task maint_read_check_bits(int index, int way, int word, int filter_no, output longint data);
  extern virtual task maint_write_data(int data);
  extern virtual function void maint_check_data(int index, int way, int filter_no, longint data, longint check_data);
  extern virtual function void maint_check_check_bits(int index, int way, int word, int filter_no, longint data, longint check_data); 			    
endclass // dce_maint_seq

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task dce_maint_seq::body;
   bit [5:0] word;
   int 	     f,s,w,cur_word,cur_word_width;
   longint unsigned	     check_data;
   <%=obj.BlockId%>_con::cacheAddress_t sfi_addr;           

   int check_data_index;
   int car_val;
   int filter_no,i;
   string maint_test_type;
   string arg_value;
   uvm_objection main_done;
   dce_csr_maint_random_obj rand_obj;
   int 	  sf_nSets[int];
   int 	  sf_nWays[int];
   rand_obj = new();			  
   rand_obj.wt_maint_recall_all = wt_maint_recall_all;
   rand_obj.wt_maint_recall_addrs = wt_maint_recall_addrs;
   rand_obj.wt_maint_recall_loc = wt_maint_recall_loc;
   rand_obj.wt_maint_recall_vb = wt_maint_recall_vb;
   `uvm_info(get_full_name(), $sformatf("DEBUG wt_maint_recall_all = %0d, wt_maint_recall_addrs = %0d, wt_maint_recall_loc = %0d", rand_obj.wt_maint_recall_all, rand_obj.wt_maint_recall_addrs, rand_obj.wt_maint_recall_loc), UVM_MEDIUM)
   `uvm_info(get_full_name(),"start inserting maintenance operations", UVM_MEDIUM)
   while(m_csm.transactionPending()) begin
      rand_obj.randomize();	
      filter_no = rand_obj.filter_no;
      case(rand_obj.maint_xact_type)			  
	0 : begin
	   `uvm_info(get_full_name(),$sformatf("inserting recall all for filter %0d",filter_no), UVM_MEDIUM);
	   maint_start_op(4'h4, filter_no);
	   maint_wait_inactive();
	end		  
	1 : begin
/*	   i = $urandom_range(num_expected_addresses - 1,0);	
	   `uvm_info(get_full_name(),$sformatf("inserting recall for addr 0x%0h with security = %0d for filter %d", m_expected_addrs[i], m_expected_addrs[i] >> <%=obj.BlockId + '_con'%>::SecureCacheAddrLsb, filter_no),UVM_MEDIUM);
	   maint_write_addr(m_expected_addrs[i] >> 6);
	   maint_start_op(4'h6, filter_no, m_expected_addrs[i] >> <%=obj.BlockId + '_con'%>::SecureCacheAddrLsb);
	   maint_wait_inactive(); */
	end		  
	2 : begin
	   s = $urandom_range(sf_nSets[filter_no] - 1, 0);	  
	   w = $urandom_range(sf_nWays[filter_no] - 1, 0);
	   f = filter_no;	  
	   `uvm_info(get_full_name(),$sformatf("inserting recall for loc for set= %0d,way = %0d for filter %d", s,w, filter_no),UVM_MEDIUM);
	   maint_write_loc(s,w,0); //0 for word because it doesn't matter for recall locs
	   maint_start_op(4'h5, f);
	   maint_wait_inactive();
	end		  
	3 : begin
	   `uvm_info(get_full_name(),$sformatf("inserting recall all for filter %0d",filter_no), UVM_MEDIUM);
	   maint_start_op(4'h8, filter_no);
	   maint_wait_inactive();
	end
      endcase	
   end				 
endtask // body


//------------------------------------------------------------------------------
// Register Access Utilities
//------------------------------------------------------------------------------
 task dce_maint_seq::reg_rmwrite(string reg_name,bit [31:0] data);
   bit [1:0] rsp;
   ocp_pkt_t m_pkt;
   m_pkt = new();
   if(regs.reg_name.exists(reg_name)) begin
    `uvm_info("BODY",$sformatf("reg name : %s,wr_data = %x",reg_name,data), UVM_HIGH);
     r_addr          = regs.reg_addr[reg_name];
   end else begin
     `uvm_fatal("BODY",$sformatf("reg name : %s does not exist",reg_name)); 
   end
   r_mask          = mask_data(reg_name);
   reg_read(reg_name, rd_data);

   m_pkt = new();			    
   			    
   wr_data = (rd_data & ~r_mask) | (data & r_mask);
   $display("DEBUG: rd_data_mask = %0h data_shift = %0h", (rd_data & ~r_mask) , (data << regs.reg_lsb[reg_name]));   
   `uvm_info("BODY",$sformatf(" write: reg name : %s,rd_data = 0x%0x mask_data = 0x%0x wr_data = 0x%0x",reg_name, rd_data, r_mask, wr_data), UVM_NONE);
   reg_write(reg_name, wr_data);
   $display("DEBUG: rd_data = %0h data = %0h r_mask = %0h m_pkt.MData = %0h", rd_data, data, r_mask, m_pkt.MData);
 endtask // reg_rmwrite

task  dce_maint_seq::reg_write(string reg_name,bit [31:0] data, input int regnum = 0);
   ocp_pkt_t m_pkt;
   string cur_reg_name;
   bit [1:0] rsp;
   if(regnum > 0)
	 cur_reg_name = $sformatf("%s%d",reg_name, regnum);
   else 
	 cur_reg_name = reg_name;	 
  `uvm_info("BODY",$sformatf("reg name : %s,wr_data = %x",cur_reg_name,data), UVM_LOW)

  r_mask = mask_data(reg_name);

   if(regs.reg_name.exists(reg_name)) begin
    `uvm_info("BODY",$sformatf("reg name : %s,wr_data = %x",cur_reg_name,data), UVM_HIGH);
     r_addr = regs.reg_addr[reg_name] + (regnum << 2);
   end else begin
     `uvm_fatal("BODY",$sformatf("reg name : %s does not exist",cur_reg_name)); 
   end
   r_mask = mask_data(reg_name);

   m_pkt = new();
   m_pkt.MAddr = r_addr;
   m_pkt.MData = data;
   m_pkt.MCmd = ocp_mcmd_t'(WRNP);
   m_ocp_agent.m_ocp_driver.send_req(m_pkt);
   m_ocp_agent.m_ocp_driver.rcv_req(m_pkt);
   rsp = m_pkt.SResp;

endtask:reg_write

task dce_maint_seq::reg_wait_for_value(bit [31:0] data,string reg_name,output bit [31:0] rd_data);
      ocp_pkt_t m_pkt;
   bit [31:0] r_data;
   m_pkt = new();
   if(regs.reg_name.exists(reg_name)) begin
    `uvm_info("BODY",$sformatf("reg name : %s,wr_data = %x",reg_name,rd_data), UVM_HIGH);
       r_addr          = regs.reg_addr[reg_name];
     end else begin
       `uvm_fatal("BODY",$sformatf("reg name : %s does not exist",reg_name)); 
     end
     r_mask = mask_data(reg_name);
    //---------------------------------------------------------------
    // Reading register for read modified write 
    //---------------------------------------------------------------
    do 
     begin
	m_pkt.MAddr = r_addr;
	m_pkt.MCmd = ocp_mcmd_t'(RD);
	m_ocp_agent.m_ocp_driver.send_req(m_pkt);
	m_ocp_agent.m_ocp_driver.rcv_req(m_pkt);
	rd_data = m_pkt.SData;
	r_data = (rd_data & r_mask); 
	`uvm_info("RUN_MAIN",$sformatf("wait function loop: reg name : %s,reg_addr = %x,rd_data = %x,expected_value = %x %s",reg_name,r_addr,rd_data,data,m_pkt.sprint_pkt()), UVM_NONE);
      #(20ns);
      end while(r_data != data);
      `uvm_info("RUN_MAIN",$sformatf("wait function: reg name : %s,reg_addr = %x,rd_data = %x,expected_value = %x",reg_name,r_addr,rd_data,data), UVM_NONE);
endtask:reg_wait_for_value

task dce_maint_seq::reg_read(string reg_name,output bit [31:0] rd_data , input int regnum = 0);
   string cur_reg_name = reg_name;
      ocp_pkt_t m_pkt;
   m_pkt = new();
   if(regnum > 0)
      cur_reg_name = $sformatf("%s%d",reg_name,regnum);
   else
      cur_reg_name = reg_name;			    
   if(regs.reg_name.exists(reg_name)) begin
    `uvm_info("BODY",$sformatf("reg name : %s,wr_data = %x",cur_reg_name,rd_data), UVM_HIGH);
     r_addr = regs.reg_addr[reg_name] + (regnum << 2);
    `uvm_info("BODY",$sformatf("reg name : %s has addr 0x%0x",cur_reg_name, r_addr), UVM_NONE); 
   end else begin
     `uvm_fatal("BODY",$sformatf("reg name : %s does not exist",cur_reg_name)); 
   end
  //---------------------------------------------------------------
  // Reading register  
  //---------------------------------------------------------------
   m_pkt.MAddr = r_addr;
   m_pkt.MCmd = ocp_mcmd_t'(RD);
   m_ocp_agent.m_ocp_driver.send_req(m_pkt);
   m_ocp_agent.m_ocp_driver.rcv_req(m_pkt);
   rd_data = m_pkt.SData;
   `uvm_info("RUN_MAIN",$sformatf("reg name : %s,reg_addr = %x,rd_data = %x",reg_name,r_addr,rd_data), UVM_NONE);

endtask:reg_read

function bit [31:0] dce_maint_seq::mask_data(string name);

  lsb  = regs.reg_lsb[name];
  msb  = regs.reg_msb[name];
  Rsvd = regs.reg_rsvd[name];
  mask_data =  0;

  for(int i=0;i<32;i++)begin
    if(Rsvd != "RSVD")begin
      if(i>=lsb &&  i<=msb)begin
        mask_data[i] = 1;
     end
    end
   end

  `uvm_info("RUN_MAIN",$sformatf("reg name : %s,mask_data = %x",name,mask_data), UVM_MEDIUM);

endfunction: mask_data

//------------------------------------------------------------------------------
// Maintenance operation utilities
//------------------------------------------------------------------------------
task dce_maint_seq::maint_wait_inactive();
   reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
endtask // maint_wait_inactive
		 
task dce_maint_seq::maint_start_op(bit [3:0] opcode, bit[4:0] filter_no, <% if(obj.wSecurityAttribute > 1) {%> bit [<%=obj.wSecurityAttribute -1 %>:0] security_bits <% } else { %> bit security_bits <% } %> = 0);
   wr_data = 0;			       
<% if(obj.wSecurityAttribute > 1) { %>			       
   wr_data[<%=obj.wSecurityAttribute + 21%>:21] = security_bits;
<% } else {%>				    
   wr_data[21] = security_bits;
<% } %>
   wr_data[20:16] = filter_no; //Snoop Filter Identifier
   wr_data[3:0] = opcode; //Opcode=Write Entry at Index, Way, and Word
   maint_wait_inactive();
   reg_write("DCEUSFMCR_SfMntOp", wr_data);
endtask // start_maint_op

//------------------------------------------------------------------------------
// Write location register using index, way, and word
//------------------------------------------------------------------------------
task dce_maint_seq::maint_write_loc(int index, int way, int word);
	wr_data = 0;		   
	wr_data[19:0] = index; //set index
	wr_data[25:20] = way; //way
	wr_data[31:26] = word;
	reg_write("DCEUSFMLR0_MntWay", wr_data);
endtask // maint_write_loc
//------------------------------------------------------------------------------
// Write location register using addr for recall
//------------------------------------------------------------------------------

task dce_maint_seq::maint_write_addr(longint addr);
	wr_data = addr & 32'hffffffff;		   
	reg_write("DCEUSFMLR0_MntWay", wr_data);
	wr_data = (addr >> 32) & 32'hffffffff;	
	reg_write("DCEUSFMLR1_MntAddr", wr_data);
endtask // maint_write_loc

//------------------------------------------------------------------------------
// Write to data register
//------------------------------------------------------------------------------
			       
task dce_maint_seq::maint_write_data(int data);
	 wr_data = data;
       reg_write("DCEUSFMDR_MntData", wr_data);		     
endtask // maint_write_data

//------------------------------------------------------------------------------
// Compare two data points at index, way, word
//------------------------------------------------------------------------------
			       
function void dce_maint_seq::maint_check_data(int index, int way, int filter_no, longint data, longint check_data);
     if (data != check_data) begin
	`uvm_error(get_type_name(),$sformatf("Read Entry at Index Way Word doesn't match Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, sf=%0d", data, check_data, index, way, filter_no));
   end
     else begin
	`uvm_info(get_full_name(),$sformatf("Read Entry at Index Way Word matches Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, sf=%0d", data, check_data, index, way, filter_no), UVM_LOW);
     end
endfunction // maint_check_data

function void dce_maint_seq::maint_check_check_bits(int index, int way, int word, int filter_no, longint data, longint check_data);
     if (data != check_data) begin
	`uvm_error(get_type_name(),$sformatf("Check Bits at Index Way Word doesn't match Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, sf=%0d", data, check_data, index, way, filter_no));
   end
     else begin
	`uvm_info(get_full_name(),$sformatf("Check Bits at Index Way Word matches Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, sf=%0d", data, check_data, index, way, filter_no), UVM_MEDIUM);
     end
endfunction // maint_check_data
			       
//------------------------------------------------------------------------------
// Write an entire entry
//------------------------------------------------------------------------------
			       
task dce_maint_seq::maint_write_entry(int index, int way, int filter_no,  bit [<%=sf_memWidth_max - 1%>:0] data);
       int cur_width = sf_memWidth[filter_no];
       int cur_word = 0;		       
       maint_wait_inactive();
       `uvm_info(get_full_name(), $sformatf("Writing following: wr_data=%x, set=%0d, way=%0d, word=%0d sf=%0d", data, index, way, cur_word,filter_no), UVM_MEDIUM)
       while(cur_width > 0) begin
	  maint_write_loc(index, way, cur_word);
          maint_write_data((data & (32'hFFFFFFFF << (32*cur_word))) >> (32*cur_word));
	  maint_start_op(4'he, filter_no);
	  cur_width = cur_width - 32;		       
	  cur_word++;		       
       end

endtask // maint_write_entry

//------------------------------------------------------------------------------
// Read an entire entry
//------------------------------------------------------------------------------

			       
task dce_maint_seq::maint_read_entry(int index, int way, int filter_no, output bit [<%=sf_memWidth_max - 1%>:0] data);
       int cur_width = sf_memWidth[filter_no];
       int cur_word = 0;

       maint_wait_inactive();

       while(cur_width > 0) begin
	 maint_write_loc(index, way, cur_word);
	 maint_start_op(4'hc, filter_no);
	 maint_wait_inactive();

         reg_read("DCEUSFMDR_MntData", rd_data);
	 data = (rd_data << (32*cur_word)) | data;   
	 cur_width = cur_width - 32;		       
	 cur_word++;		       
       end
       `uvm_info(get_full_name(), $sformatf("Reading following: wr_data=%x, set=%0d, way=%0d, word=%0d sf=%0d", data, index, way, cur_word,filter_no), UVM_MEDIUM)    

endtask // maint_read_entry
//------------------------------------------------------------------------------
// Write an entire entry
//------------------------------------------------------------------------------
			       
task dce_maint_seq::maint_write_check_bits(int index, int way, int word, int filter_no, longint data);
       maint_wait_inactive();
       `uvm_info(get_full_name(), $sformatf("Writing following check bits: check_bit_data=%x, set=%0d, way=%0d, word=%0d sf=%0d", data, index, way, word,filter_no), UVM_LOW)
       maint_write_loc(index, way,word);
       maint_write_data(data & 1'h1);
       maint_start_op(4'hf, filter_no);

endtask // maint_write_entry

//------------------------------------------------------------------------------
// Read an entire entry
//------------------------------------------------------------------------------

			       
task dce_maint_seq::maint_read_check_bits(int index, int way, int word, int filter_no, output longint data);
       int cur_width = sf_memWidth[filter_no];
       int cur_word = 0;		       
       maint_wait_inactive();
       maint_write_loc(index, way, word);
       maint_start_op(4'hd, filter_no);
       maint_wait_inactive();
       reg_read("DCEUSFMDR_MntData", rd_data);
       data = rd_data & 1'h1;		       
endtask // maint_read_check_bits

