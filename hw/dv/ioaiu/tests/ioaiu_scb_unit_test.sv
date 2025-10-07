import <%=obj.BlockId%>_env_pkg::*;
import <%=obj.BlockId%>_axi_agent_pkg::*;
import <%=obj.BlockId%>_smi_agent_pkg::*;

class ioaiu_scb_unit_test extends uvm_test;
   ioaiu_scoreboard m_scb;
   `uvm_component_utils(ioaiu_scb_unit_test)
   
   extern function void testSingleDvm();

   extern function axi4_read_addr_pkt_t  genAxiReadAddr();
   extern function axi4_read_data_pkt_t  genAxiReadData();
   extern function axi4_write_addr_pkt_t genAxiWriteAddr();   
   extern function axi4_write_data_pkt_t genAxiWriteData();

   extern function smi_seq_item          genCmdReqRead(axi4_read_addr_pkt_t axi_pkt);
   extern function smi_seq_item          genCmdReqWrite(axi4_write_addr_pkt_t axi_pkt);
   extern function smi_seq_item          genDvmSnpReq(axi4_read_addr_pkt_t axi_pkt);
   extern function smi_seq_item          genCmdRsp(smi_seq_item smi_pkt);
   extern function smi_seq_item          genDtwReq();
   extern function smi_seq_item          genDtwRsp();
   extern function smi_seq_item          genDtrReq(smi_seq_item smi_pkt);
   extern function smi_seq_item          genDtrRsp(smi_seq_item smi_pkt);
   extern function smi_seq_item          genStrReq();
   extern function smi_seq_item          genStrRsp();
   extern function smi_seq_item          genSnpReq();
   extern function smi_seq_item          genSnpRsp();

   function new(string name="ioaiu_scb_unit_test", uvm_component parent=null);
      super.new(name,parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      m_scb = ioaiu_scoreboard::type_id::create("ioaiu_scoreboard",this);
   endfunction

   task run_phase(uvm_phase phase);
      uvm_objection uvm_obj = phase.get_objection();
      phase.raise_objection(this);
//      testSingleRead();
      phase.drop_objection(this);
   endtask : run_phase
   
endclass : ioaiu_scb_unit_test

function void ioaiu_scb_unit_test::testSingleRead();
   axi4_read_addr_pkt_t     send_pkt;
   smi_seq_item             cmd_req, cmd_rsp, dtr_req, dtr_rsp, str_req, str_rsp;
   
   int                     m_tmp_qA[$], m_tmp_qB[$];
   int                     fail = 0;
   
//   smi_seq_item     m_pkt,tmp_pkt,send_pkt;
//   ace_read_addr_pkt_t     m_read_addr_pkt,tmp_read_addr_pkt,send_read_addr_pkt;
//   ace_write_addr_pkt_t    m_write_addr_pkt,tmp_write_addr_pkt,send_write_addr_pkt;
//   ace_read_data_pkt_t     m_read_data_pkt,tmp_read_data_pkt,send_read_data_pkt;
//   ace_write_data_pkt_t    m_write_data_pkt,tmp_write_data_pkt,send_write_data_pkt;

   send_pkt = genAxiReadAddr();
   m_scb.write_ncbu_read_addr_chnl(send_pkt);
   m_tmp_qA = {};
   m_tmp_qA = m_scb.m_ott_q.find_index with ((item.isRead                                     === 1 &&
                                        item.m_ace_read_addr_pkt.araddr                 === send_pkt.araddr && 
					item.m_ace_read_addr_pkt.arid                   === send_pkt.arid   ) 
                                       );
   if(m_tmp_qA.size <= 0) begin
      for(int i=0; i < m_scb.m_ott_q.size(); i++) begin
	 `uvm_info("DCDEBUG",$sformatf("printing ott %0d",i),UVM_NONE)
	 m_scb.m_ott_q[i].print_me();
      end
      
     `uvm_error("", $sformatf("FAIL! AXIRead Test #1: No AXIRead in the SCB TXNs!"))
   end

   cmd_req = genCmdReqRead(send_pkt);
   m_scb.write_ioaiu_smi_port(cmd_req);

   m_tmp_qA = {};
   m_tmp_qA = m_scb.m_ott_q.find_index with ((item.isRead                                     === 1 &&
                                        item.m_cmd_req_pkt.smi_msg_id                 === cmd_req.smi_msg_id && 
                                        item.m_ace_read_addr_pkt.araddr                 === send_pkt.araddr && 
					item.m_ace_read_addr_pkt.arid                   === send_pkt.arid   ) 
                                       );
   if(m_tmp_qA.size <= 0) begin
      for(int i=0; i < m_scb.m_ott_q.size(); i++) begin
	 `uvm_info("DCDEBUG",$sformatf("printing ott %0d",i),UVM_NONE)
	 m_scb.m_ott_q[i].print_me();
      end
      
     `uvm_error("", $sformatf("FAIL! AXIRead Test #2: No matching CmdReq in our SCB TXNs!"))
   end

   cmd_rsp = genCmdRsp(cmd_req);
   m_scb.write_ioaiu_smi_port(cmd_rsp);
   m_tmp_qA = {};

   m_tmp_qA = m_scb.m_ott_q.find_index with ((item.isRead                                     === 1 &&
                                        item.m_cmd_rsp_pkt.smi_msg_id                 === cmd_rsp.smi_msg_id &&
                                        item.m_ace_read_addr_pkt.araddr                 === send_pkt.araddr && 
					item.m_ace_read_addr_pkt.arid                   === send_pkt.arid   ) 
                                       );
   if(m_tmp_qA.size <= 0) begin
      for(int i=0; i < m_scb.m_ott_q.size(); i++) begin
	 `uvm_info("DCDEBUG",$sformatf("printing ott %0d",i),UVM_NONE)
	 m_scb.m_ott_q[i].print_me();
      end
      
     `uvm_error("", $sformatf("FAIL! AXIRead Test #3: No matching CmdReq in our SCB TXNs!"))
   end

   dtr_req = genDtrReq(cmd_req);
   m_scb.write_ioaiu_smi_port(dtr_req);
   m_tmp_qA = {};
   m_tmp_qA = m_scb.m_ott_q.find_index with ((item.isRead                             === 1 &&
                                        item.m_dtr_req_pkt.size()             > 0  &&
                                        item.m_cmd_req_pkt.smi_msg_id                 === dtr_req.smi_rmsg_id ) 
                                       );
   if(m_tmp_qA.size <= 0) begin
      fail = 1;
   end
   else begin
      if(m_scb.m_ott_q[m_tmp_qA[0]].m_dtr_req_pkt[0].smi_rmsg_id != cmd_req.smi_msg_id)
	fail = 1;
   end
   if(fail == 1) begin
      for(int i=0; i < m_scb.m_ott_q.size(); i++) begin
	 `uvm_info("DCDEBUG",$sformatf("printing ott %0d",i),UVM_NONE)
	 m_scb.m_ott_q[i].print_me();
      end
      
     `uvm_error("", $sformatf("FAIL! AXIRead Test #4: No matching DtrReq in our SCB TXNs!"))
   end



   dtr_rsp = genDtrRsp(dtr_req);
   m_scb.write_ioaiu_smi_port(dtr_rsp);
   m_tmp_qA = {};
   m_tmp_qA = m_scb.m_ott_q.find_index with ((item.isRead                             === 1 &&
					      item.m_cmd_req_pkt.smi_msg_id           === dtr_req.smi_rmsg_id &&
                                              item.m_dtr_rsp_pkt.size()             > 0 ) 
                                       );
   if(m_tmp_qA.size <= 0) begin
      fail = 1;
   end
   else begin
      if(m_scb.m_ott_q[m_tmp_qA[0]].m_dtr_rsp_pkt[0].smi_rmsg_id != dtr_req.smi_msg_id)
	fail = 1;
   end
   
   if(m_tmp_qA.size <= 0) begin
      fail = 1;
   end
   if(fail == 1) begin
      for(int i=0; i < m_scb.m_ott_q.size(); i++) begin
	 `uvm_info("DCDEBUG",$sformatf("printing ott %0d",i),UVM_NONE)
	 m_scb.m_ott_q[i].print_me();
      end
      
     `uvm_error("", $sformatf("FAIL! AXIRead Test #5: No matching DtrRsp in our SCB TXNs!"))
   end
   
endfunction : testSingleRead


function axi4_read_addr_pkt_t  ioaiu_scb_unit_test::genAxiReadAddr();
   ace_read_addr_pkt_t     m_pkt,tmp_pkt,send_pkt;
   m_pkt = ace_read_addr_pkt_t::type_id::create("test");
   tmp_pkt = ace_read_addr_pkt_t::type_id::create("test");
   m_pkt.randomize();
   tmp_pkt.copy(m_pkt);
   $cast(send_pkt, tmp_pkt);
   return send_pkt;
endfunction
function axi4_read_data_pkt_t  ioaiu_scb_unit_test::genAxiReadData();
endfunction
function axi4_write_addr_pkt_t  ioaiu_scb_unit_test::genAxiWriteAddr();
endfunction
function axi4_write_data_pkt_t  ioaiu_scb_unit_test::genAxiWriteData();
endfunction

function smi_seq_item  ioaiu_scb_unit_test::genDvmSnpReq(int dvm_snp_no);
   smi_seq_item m_pkt,tmp_pkt,send_pkt;
   m_pkt = smi_seq_item::type_id::create("test");
   tmp_pkt = smi_seq_item::type_id::create("test");
   m_pkt.randomize() with {
      smi_msg_type == SNP_DVM_MSG;
      smi_addr[3]  == dvm_snp_no;
   };
   tmp_pkt.copy(m_pkt);
   $cast(send_pkt, tmp_pkt);
   return send_pkt;   
endfunction : genDvmSnpReq


function smi_seq_item  ioaiu_scb_unit_test::genCmdReqRead(axi4_read_addr_pkt_t axi_pkt);
   smi_seq_item m_pkt,tmp_pkt,send_pkt;
   m_pkt = smi_seq_item::type_id::create("test");
   tmp_pkt = smi_seq_item::type_id::create("test");
   m_pkt.randomize() with {
      smi_msg_type == CMD_RD_NOT_SHD;
      m_pkt.smi_addr == axi_pkt.araddr;
   };
   
   tmp_pkt.copy(m_pkt);
   $cast(send_pkt, tmp_pkt);
   return send_pkt;   
endfunction
function smi_seq_item  ioaiu_scb_unit_test::genCmdReqWrite(axi4_write_addr_pkt_t axi_pkt);
   smi_seq_item     m_pkt,tmp_pkt,send_pkt;
   m_pkt = smi_seq_item::type_id::create("test");
   tmp_pkt = smi_seq_item::type_id::create("test");
//   m_pkt.randomize() with {
//      smi_msg_type == CMD_WR_NOT_SHD;
//   };
   
   tmp_pkt.copy(m_pkt);
   $cast(send_pkt, tmp_pkt);
   return send_pkt;   
endfunction

function smi_seq_item  ioaiu_scb_unit_test::genCmdRsp(smi_seq_item smi_pkt);
   smi_seq_item m_pkt,tmp_pkt,send_pkt;
   m_pkt = smi_seq_item::type_id::create("test");
   tmp_pkt = smi_seq_item::type_id::create("test");
   m_pkt.randomize() with {
      m_pkt.smi_msg_type == C_CMD_RSP;
      m_pkt.smi_rmsg_id == smi_pkt.smi_msg_id;
   };
   
   tmp_pkt.copy(m_pkt);
   $cast(send_pkt, tmp_pkt);
   return send_pkt;   
endfunction

function smi_seq_item  ioaiu_scb_unit_test::genDtrReq(smi_seq_item smi_pkt);
   smi_seq_item m_pkt,tmp_pkt,send_pkt;
   m_pkt = smi_seq_item::type_id::create("test");
   tmp_pkt = smi_seq_item::type_id::create("test");
   m_pkt.randomize() with {
      m_pkt.smi_msg_type == DTR_DATA_UNQ_CLN;
      m_pkt.smi_rmsg_id  == smi_pkt.smi_msg_id;
   };
   
   tmp_pkt.copy(m_pkt);
   $cast(send_pkt, tmp_pkt);
   return send_pkt;   
endfunction
function smi_seq_item  ioaiu_scb_unit_test::genDtrRsp(smi_seq_item smi_pkt);
   smi_seq_item m_pkt,tmp_pkt,send_pkt;
   m_pkt = smi_seq_item::type_id::create("test");
   tmp_pkt = smi_seq_item::type_id::create("test");
   m_pkt.randomize() with {
      m_pkt.smi_msg_type == DTR_RSP;
      m_pkt.smi_rmsg_id  == smi_pkt.smi_msg_id;
   };
   
   tmp_pkt.copy(m_pkt);
   $cast(send_pkt, tmp_pkt);
   return send_pkt;   
endfunction

function smi_seq_item  ioaiu_scb_unit_test::genDtwReq();
endfunction
function smi_seq_item  ioaiu_scb_unit_test::genDtwRsp();
endfunction

function smi_seq_item  ioaiu_scb_unit_test::genStrReq();
endfunction
function smi_seq_item  ioaiu_scb_unit_test::genStrRsp();
endfunction

function smi_seq_item  ioaiu_scb_unit_test::genSnpReq();
endfunction
function smi_seq_item  ioaiu_scb_unit_test::genSnpRsp();
endfunction

module top;
   import uvm_pkg::*;
   `include "uvm_macros.svh"
   initial begin
      run_test("ioaiu_scb_unit_test");
      $finish;
   end

endmodule // top

   
