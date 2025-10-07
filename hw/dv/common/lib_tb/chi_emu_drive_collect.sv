<% if(obj.testBench=="emu") { %>

    `uvm_analysis_imp_decl(_req_dri)     
    `uvm_analysis_imp_decl(_dat_dri)
    `uvm_analysis_imp_decl(_rsp_dri)
    //`uvm_analysis_imp_decl( _rsp_dri )
    //`uvm_analysis_imp_decl( _snp_dri )

class chi_emu_drive_collect extends uvm_component;
     <% if(obj.testBench=="emu") { %>
        virtual <%=obj.BlockId%>_chi_emu_if drive_collect_vif; <% } %>

   `uvm_component_utils(chi_emu_drive_collect)

   bit [(256 - 1): 0]  data_check  [bit [(48 - 1): 0]];
   bit [(256 - 1): 0] read_data_check_exp;
   bit [(256 - 1): 0] read_data_check_act;
   bit [(256 - 1): 0] prep_wrexp_data;

   //QUEUE FOR PACKET STORE
   chi_base_seq_item pkt_base[$];
   chi_req_seq_item  pkt_req[$];
   chi_req_seq_item  pkt_wrreq[$];
   chi_req_seq_item  pkt_rdreq[$];
   chi_dat_seq_item  pkt_dat[$];
   chi_rsp_seq_item  pkt_rsp[$];
   chi_snp_seq_item  pkt_snp[$];

   // PACKETS
   chi_base_seq_item base_pkt;
   chi_req_seq_item  req_pkt;
   chi_dat_seq_item  dat_pkt;
   chi_rsp_seq_item  rsp_pkt;
   chi_snp_seq_item  snp_pkt;

   chi_req_seq_item  req_pkt_a;
   chi_dat_seq_item  dat_pkt_a;
   chi_agent_cfg     m_cfg;

   //ANALYSIS PORT DECLARATION
   uvm_analysis_imp_req_dri#(chi_req_seq_item, chi_emu_drive_collect) req_export;
   uvm_analysis_imp_dat_dri#(chi_dat_seq_item, chi_emu_drive_collect) dat_export;
   uvm_analysis_imp_rsp_dri#(chi_rsp_seq_item, chi_emu_drive_collect) rsp_export;

  
   function new (string name, uvm_component parent);
       super.new(name, parent);
   endfunction : new

   //BUILD PHASE
   function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       $display("To check if node works");
    if(!uvm_config_db#(virtual <%=obj.BlockId%>_chi_emu_if)::get(this, "", "<%=obj.BlockId%>_chi_emu_if", drive_collect_vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".drive_collect_vif"});
       req_export = new("req_export", this);
       dat_export = new("dat_export", this);
       rsp_export = new("rsp_export", this);
   endfunction: build_phase
  
   // WRITE METHOD 
   virtual function void write_req_dri(chi_req_seq_item pkt);
       req_pkt = new();
       req_pkt.copy(pkt);
       pkt_req.push_back(req_pkt);
   `uvm_info(get_name,$psprintf(" DRIVE_COLLECT_REQ : req_addr : %0h req_q_size : %0d opcode is %s",req_pkt.addr, pkt_req.size(), req_pkt.opcode.name()),UVM_LOW);
   endfunction : write_req_dri

   virtual function void write_dat_dri(chi_dat_seq_item pkt);
       dat_pkt = new();                              
       dat_pkt.copy(pkt); 
       pkt_dat.push_back(dat_pkt);
   `uvm_info(get_name,$psprintf(" DRIVE_COLLECT_DATA : dat_data : %h dat_q_size : %d opcode is %s",dat_pkt.data, pkt_dat.size(),dat_pkt.opcode.name()),UVM_LOW);
   endfunction : write_dat_dri

   virtual function void write_rsp_dri(chi_rsp_seq_item pkt);
       rsp_pkt = new();                              
       rsp_pkt.copy(pkt); 
       pkt_rsp.push_back(rsp_pkt);
   endfunction : write_rsp_dri

virtual task run_phase(uvm_phase phase);
   super.run_phase(phase);
       forever  begin 
             $display($time,"I am stuck here");
             wait4clk_event();
              // #10;
             wait ((pkt_req.size() > 0)  || (pkt_dat.size() > 0));
             $display($time,"I am stuck here2 req_size is %0h dat_size %0h",pkt_req.size(),pkt_dat.size());
             if ((pkt_req.size() > 0)) begin
                 req_pkt_a = new();
                 req_pkt_a = pkt_req.pop_front();
                 `uvm_info(get_name,$psprintf(" DRIVE_COLLECT_WRREQ_ST OPCODE : %s", req_pkt_a.opcode.name),UVM_LOW);
                 prepare_req(); 
                 if ((req_pkt_a.opcode.name == "WRITENOSNPPTL" || req_pkt_a.opcode.name == "WRITENOSNPFULL"))begin
                         wait ((pkt_dat.size() > 0));
                         dat_pkt_a = new();
                         dat_pkt_a = pkt_dat.pop_front();
                         `uvm_info(get_name,$psprintf("DRIVE_COLLECT_DATA_ST"),UVM_LOW);
                         prepare_data(); 
                         $display($time,"I am here before write_data");
                         drive_collect_vif.chk_wr_data(); 
                         prep_wrexp_data = 'h0;
                         data_check[req_pkt_a.addr] = prep_wrexp_data; 
                 end
                 else if (req_pkt_a.opcode.name == "READNOSNP"  || req_pkt_a.opcode.name == "CLEANUNIQUE") begin
                      drive_collect_vif.chk_rd_data();
                      read_data_check_exp = data_check[req_pkt_a.addr];
                      `uvm_info(get_name,$psprintf("CHECKING_DATA_HERE : %0h Addr is : %0h",data_check[req_pkt_a.addr],req_pkt_a.addr),UVM_LOW);
                       end
              end 
      end
 endtask : run_phase

 task wait4clk_event();
     m_cfg.wait4clk_event("chi_emu_drive_collect");
    `uvm_info(get_name(), $psprintf("CHI_EMU_DRIVE_COLLECT : waitforclk_called"), UVM_LOW) //D
 endtask: wait4clk_event

 virtual task prepare_req();
   drive_collect_vif.req_rsvdc        = req_pkt_a.rsvdc ;     
   drive_collect_vif.req_tracetag     = req_pkt_a.tracetag ; 
   drive_collect_vif.req_expcompack   = req_pkt_a.expcompack;
   drive_collect_vif.req_excl         = req_pkt_a.excl   ;   
   drive_collect_vif.req_lpid         = req_pkt_a.lpid    ;  
   drive_collect_vif.req_snpattr      = req_pkt_a.snpattr ;   
   drive_collect_vif.req_memattr      = req_pkt_a.memattr  ; 
   drive_collect_vif.req_pcrdtype     = req_pkt_a.pcrdtype ; 
   drive_collect_vif.req_order        = req_pkt_a.order ;    
   drive_collect_vif.req_allowretry   = req_pkt_a.allowretry;
   drive_collect_vif.req_likelyshared = req_pkt_a.likelyshared ;
   drive_collect_vif.req_ns	   = req_pkt_a.ns;	
   drive_collect_vif.req_addr         = req_pkt_a.addr  ;
   drive_collect_vif.req_size         = req_pkt_a.size ; 
   drive_collect_vif.req_opcode       = req_pkt_a.opcode ;
   drive_collect_vif.req_txnid        = req_pkt_a.txnid ;
   drive_collect_vif.req_tgtid        = req_pkt_a.tgtid ;
   drive_collect_vif.req_qos          = req_pkt_a.qos ;  
 endtask : prepare_req

 virtual task prepare_data();
   drive_collect_vif.data_rsvdc    =  dat_pkt_a.rsvdc ;   
   drive_collect_vif.data_data     =  dat_pkt_a.data;    
   drive_collect_vif.data_be       =  dat_pkt_a.be  ;    
   drive_collect_vif.data_tracetag =  dat_pkt_a.tracetag;
   drive_collect_vif.data_ccid     =  dat_pkt_a.ccid   ; 
   drive_collect_vif.data_dataid   =  dat_pkt_a.dataid  ;
   drive_collect_vif.data_dbid     =  dat_pkt_a.dbid  ;  
   //drive_collect_vif.data_order  =  dat_pkt_a.order  ; 
   drive_collect_vif.data_datapull =  dat_pkt_a.datapull;
   drive_collect_vif.data_resp     =  dat_pkt_a.resp  ; 
   drive_collect_vif.data_resperr  =  dat_pkt_a.resperr;
   drive_collect_vif.data_homenid  =  dat_pkt_a.homenid;
   drive_collect_vif.data_opcode   =  dat_pkt_a.opcode;
   drive_collect_vif.data_txnid    =  dat_pkt_a.txnid ;
   drive_collect_vif.data_tgtid    =  dat_pkt_a.tgtid ;
   drive_collect_vif.data_qos      =  dat_pkt_a.qos  ; 
 endtask : prepare_data

    
endclass : chi_emu_drive_collect

<% } %>

