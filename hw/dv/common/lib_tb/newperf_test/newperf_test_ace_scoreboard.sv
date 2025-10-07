////////////////////////////////////////////////////////////////////////////////
//
// Author       : Cyrille LUDWIG
// Purpose      : GENERIC (CHI,ACE ...) Scoreboard for Performance (BW & Latency) Test
// Revision     :
//                  Use with plusargs "+newperf_test_scb"
//
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"

`uvm_analysis_imp_decl ( _read_addr_port     )
`uvm_analysis_imp_decl ( _read_data_port   )
`uvm_analysis_imp_decl ( _write_addr_port     )
`uvm_analysis_imp_decl ( _write_data_port   )
`uvm_analysis_imp_decl  (_write_resp_port)
////////////////////////////////////////////////////////////////////////////////
// Section1:  Scoreboard top
//
//
////////////////////////////////////////////////////////////////////////////////

class newperf_test_ace_scb #(parameter type T_RA = axi4_read_addr_pkt_t
              				      ,parameter type T_RD = axi4_read_data_pkt_t
              				      ,parameter type T_WA = axi4_write_addr_pkt_t
              				      ,parameter type T_WD = axi4_write_data_pkt_t
              				      ,parameter type T_WR = axi4_write_resp_pkt_t
             ) extends uvm_scoreboard;
             
  `uvm_component_param_utils(newperf_test_ace_scb#(T_RA,T_RD,T_WA,T_WD,T_WR))
 
	/////////////////////////////////////////
	// CFG Attribut of configuration       //
	/////////////////////////////////////////
    // Type CHI,ACE etc...
	e_pt_type_itf  cfg_e_type = newperf_test_tools_pkg::NONE;  // Must BE CHI,ACE. With NONE scb doesn't work
	int cfg_aiu_id = -1; 
  string aiu_name ;

	//verbosity
	bit cfg_b_display_latency_graph = 1'b1;

	// END CFG //
	////////////

    ///////////////////////
	// Ports             //
    uvm_analysis_imp_read_addr_port     #(
      T_RA, newperf_test_ace_scb) read_addr_port;
    uvm_analysis_imp_read_data_port   #(
      T_RD, newperf_test_ace_scb) read_data_port;
      uvm_analysis_imp_write_addr_port     #(
        T_WA, newperf_test_ace_scb) write_addr_port;
      uvm_analysis_imp_write_data_port   #(
        T_WD, newperf_test_ace_scb) write_data_port; 
 uvm_analysis_imp_write_resp_port   #(
        T_WR, newperf_test_ace_scb) write_resp_port; 

    // event global pool
    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev_calc_bw = ev_pool.get("ev_calc_bw");
    uvm_event ev_steady_start_rd_bw = uvm_event_pool::get_global("ev_steady_start_rd_bw"); // steady_bw => first agent finished received or sent must stop off all the BW calculation 
    uvm_event ev_steady_stop_rd_bw = uvm_event_pool::get_global("ev_steady_stop_rd_bw"); // steady_bw => first agent finished received or sent must stop off all the BW calculation 
    uvm_event ev_steady_start_wr_bw = uvm_event_pool::get_global("ev_steady_start_wr_bw"); // steady_bw => first agent finished received or sent must stop off all the BW calculation 
    uvm_event ev_steady_stop_wr_bw = uvm_event_pool::get_global("ev_steady_stop_wr_bw"); // steady_bw => first agent finished received or sent must stop off all the BW calculation 

    int ioaiu_num_trans;
    int total_rd_txn;
    int total_wr_txn;
//    static uvm_event ev_linked_scb_end;

	// scoreboard attribut
	bit start_sb;

	// REMOVE FIRST TXN
	int doff_nbr_rd_tx; // remove the x first read transactions
	int doff_nbr_wr_tx; // remove the x first writetransactions

    // latency Attributs use by tools function cf below
    s_txn_timestamp q_t_read[$]; // time of the request for each '{qos,txnid,time}
    s_txn_timestamp q_t_write[$]; // time of the request for each '{qos,txnid,time}
    s_txn_timestamp q_t_write_resp[$]; // time of the request (use by bresp port)for each '{qos,txnid,time}
    int txnid_write[int]; // txnid of the request for each new_write_cnt // delete each tlast
    int new_write_addr_cnt;  // incr by 1 each new addr&id  synchrone with new_write_data_cnt
    int new_write_data_cnt;  // incr by 1 each new & first data synchron with new_write_addr_cnt
    int wr_nbr_bytes;
  	newperf_test_latency_tools read_latency_tools;
    newperf_test_latency_tools write_latency_tools;
    newperf_test_latency_tools write_resp_latency_tools;
  	newperf_test_latency_tools read_latency_tools_qos[int];
    newperf_test_latency_tools write_latency_tools_qos[int];
    newperf_test_latency_tools write_resp_latency_tools_qos[int];
    newperf_test_bw_tools read_bw_tools;
    newperf_test_bw_tools write_bw_tools;

    bit wait_rd_lastbeat;
    bit wait_wr_lastbeat;
    real     frequency;
    time     period;

    // UVM task & function
    extern function new(string name="newperf_test_ace_scb", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
   
    //check phase
    extern function void check_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);

    //Write Function for CHI port
    extern function void write_read_addr_port   ( const ref T_RA  m_pkt ) ;
    extern function void write_read_data_port   ( const ref T_RD  m_pkt ) ;
    extern function void write_write_addr_port  ( const ref T_WA  m_pkt ) ;
    extern function void write_write_data_port  ( const ref T_WD  m_pkt ) ;
    extern function void write_write_resp_port  ( const ref T_WR  m_pkt ) ;
    extern function void update_id              ( int id) ;
    extern function void report();

endclass

////////////////////////////////////////////////////////////////////////////////
// Section1:  UVM INIT TASK & FUNCTION
///////////////////////////////////////////////////////////////////////////////

//Constructor
function newperf_test_ace_scb::new(string name="newperf_test_ace_scb", uvm_component parent=null);
    super.new(name,parent);
     if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end
endfunction

function void newperf_test_ace_scb::update_id(int id);
  read_latency_tools.cfg_aiu_id = id;
  write_latency_tools.cfg_aiu_id = id;
  write_resp_latency_tools.cfg_aiu_id = id;
  read_bw_tools.cfg_aiu_id = id;
  write_bw_tools.cfg_aiu_id =id;
endfunction

//Build phase
function void newperf_test_ace_scb::build_phase(uvm_phase phase);
    
    //CHI Ports
    read_addr_port     = new("read_addr_port"     , this);
    read_data_port     = new("read_data_port"   , this);
    write_addr_port    = new("write_addr_port"     , this);
    write_data_port    = new("write_data_port"   , this);
    write_resp_port   = new("write_resp_port"   , this);

    
    read_latency_tools  = new("READ  READ_ADDR  -> 1stDATA latency",cfg_e_type,cfg_aiu_id,aiu_name);
    write_latency_tools = new("WRITE WRITE_ADDR -> 1stDATA latency",cfg_e_type,cfg_aiu_id,aiu_name);
    write_resp_latency_tools = new("WRITE WRITE_ADDR -> BRESP latency",cfg_e_type,cfg_aiu_id,aiu_name);
    read_bw_tools  = new("READ_BW  ",cfg_e_type,cfg_aiu_id,aiu_name);
    write_bw_tools = new("WRITE_BW ",cfg_e_type,cfg_aiu_id,aiu_name);

    if (cfg_aiu_id == -1) `uvm_fatal(get_full_name(), "CFG_AIU_ID isn't set")
    if (frequency == 0) `uvm_fatal(get_full_name(), "AIU Frequency isn't set")

    period = ((1/frequency) * 1000000) * 1ns;
 
endfunction

////////////////////////////////////////////////////////////////////////////////
// Section2:  UVM Write PORTs functions
////////////////////////////////////////////////////////////////////////////////
//******************************************************************************
// Function : write_read_addr_port
//******************************************************************************
function void newperf_test_ace_scb::write_read_addr_port(const ref T_RA m_pkt);
    
  ace_read_addr_pkt_t ace_packet;
  int txnid,qos;
  string str_opcode;
  ace_packet= ace_read_addr_pkt_t'(m_pkt); //$cast doesn't work in this case
  txnid=ace_packet.arid;
  qos=ace_packet.arqos;
  str_opcode=ace_packet.arcmdtype.name();

        if (start_sb) begin
        `uvm_info(`LABEL_NEWPERF, $psprintf("read_addr_port. Pktid=%0d opcode:%0s pkt@=%0h", txnid,str_opcode,m_pkt.araddr), UVM_LOW)
            if (!uvm_re_match(uvm_glob_to_re("WR*"),str_opcode)       //ACE
             || !uvm_re_match(uvm_glob_to_re("RD*"),str_opcode)       //ACE
                 ) begin // only Read or Write opcode type
               q_t_read.push_back('{qos,txnid,$realtime}); 
              `uvm_info(`LABEL_NEWPERF, $sformatf("REQUEST READ REQ start time=%0t txnid:%0d qos:%0d", $realtime, txnid,qos), UVM_LOW)
            end
      end //start_sb 
endfunction

//******************************************************************************
// Function : write_read_data_port
//******************************************************************************
function void newperf_test_ace_scb::write_read_data_port(const ref T_RD m_pkt); // actived on each beat of data
      
      int txnid=m_pkt.rid; 
      bit tlast=m_pkt.rlast;
      int tx_rd_idx[$];
      s_txn_cycle lat_cycle;
      int qos; 
      if(start_sb)begin
      
        
      `uvm_info(`LABEL_NEWPERF, $psprintf(" read_data_port. time=%0t Pktid=%0d", $realtime,txnid), UVM_LOW)
      //NewPerfTest: process read latency ON THE FIRST BEAT DATA by TXnID 
            tx_rd_idx=  q_t_read.find_first_index with (item.txnid == txnid);  
            qos=q_t_read[tx_rd_idx[0]].qos;
            if (tx_rd_idx.size()>0 && !wait_rd_lastbeat) begin 
                  time t_latency;
                  int c_latency;
                  
                  t_latency = $realtime - q_t_read[tx_rd_idx[0]].timestamp;
                  c_latency = int'(t_latency/period);
                  lat_cycle = '{qos,q_t_read[tx_rd_idx[0]].txnid,c_latency};

                  read_latency_tools.add_latency (lat_cycle);
				  if (doff_nbr_rd_tx <=0) begin:doff_rd_tx
				  `uvm_info(`LABEL_NEWPERF, $sformatf(" READ LATENCY start time=%0t  end time=%0t latency=%0t txnid,:%0d qos:%0d", q_t_read[tx_rd_idx[0]].timestamp, $realtime, t_latency,txnid,qos), UVM_LOW)
                  read_latency_tools.add_latency_graph_bystepns (t_latency);
                  read_latency_tools.add_latency_graph_bystep   (t_latency);  
          end:doff_rd_tx

                  wait_rd_lastbeat=1; // process latency only on the first beat data
          end // end if q_t_read_txnid   
    
      if (tlast) begin
                 wait_rd_lastbeat=0; //wait the last beat before recheck the txnid to avoid to recheck the txnid on the next beat of data
                  q_t_read.delete(tx_rd_idx[0]);
        end
        
	   begin:build_bw_graph
	     int nbr_bytes = m_pkt.rdata.size() * (WXDATA/8);  // here: data=64B  TODO: add dependencies with ARLEN & ARSIZE
       if (doff_nbr_rd_tx <=0) begin
         total_rd_txn++;
         if (total_rd_txn == 1) ev_steady_start_rd_bw.trigger(); // first send data after doff start ref time for steady BW 
         if (total_rd_txn == ioaiu_num_trans/2) begin
              ev_steady_stop_rd_bw.trigger();  // when reach the middle of txn dump all the steady BW
          end
	   	   read_bw_tools.add_bw_perqos(nbr_bytes,qos);
	   	   read_bw_tools.add_bw_graph_bystep(nbr_bytes,tlast);
         end else begin
		  if(tlast) begin:tlast_b		 
		 `uvm_info(`LABEL_NEWPERF, $sformatf(" DOFF READ TX  time=%0t  txnid,:%0d", $realtime,txnid), UVM_LOW)
		  doff_nbr_rd_tx--;
          end:tlast_b
	     end

       end:build_bw_graph

        end // end start_sb
endfunction
//******************************************************************************
// Function : write_write_addr_port
//******************************************************************************
function void newperf_test_ace_scb::write_write_addr_port(const ref T_WA m_pkt);
    
  int txnid=m_pkt.awid;
  int qos=m_pkt.awqos;
      
      if(start_sb)begin
        `uvm_info(`LABEL_NEWPERF, $psprintf(" write_addr_port. Pktid=%0d pkt@=%0h", m_pkt.awid,m_pkt.awaddr), UVM_LOW)
              txnid_write[new_write_addr_cnt++] = txnid;
              q_t_write.push_back('{qos,txnid,$realtime}); 
              q_t_write_resp.push_back('{qos,txnid,$realtime}); 
              `uvm_info(`LABEL_NEWPERF, $sformatf(" REQUEST WRITE_ADDR start time=%0t txnid:%0d qos:%0d", $realtime, txnid,qos), UVM_LOW)
      end //start_sb d
endfunction

//******************************************************************************
// Function : write_write_data_port
//******************************************************************************
function void newperf_test_ace_scb::write_write_data_port(const ref T_WD m_pkt);
      
      int txnid;
      bit tlast=m_pkt.wlast;
      int tx_wr_idx[$];
      s_txn_cycle lat_cycle;
      int qos; 
       
      if(start_sb)begin
            txnid=txnid_write[new_write_data_cnt];
            if (tlast) new_write_data_cnt++;
            tx_wr_idx=  q_t_write.find_first_index with (item.txnid == txnid);  
            qos=q_t_write[tx_wr_idx[0]].qos;
            if (tx_wr_idx.size()>0 && !wait_wr_lastbeat) begin 
                  time t_latency;
                  int c_latency;
                  
                  t_latency = $realtime - q_t_write[tx_wr_idx[0]].timestamp;
                  c_latency = int'(t_latency/period);
                  lat_cycle = '{qos,q_t_write[tx_wr_idx[0]].txnid,c_latency};
                   
                  if(!($test$plusargs("init_all_cache") && (doff_nbr_wr_tx > 0))) begin
                    write_latency_tools.add_latency (lat_cycle);
                  end
				  if (doff_nbr_wr_tx <=0) begin
                 `uvm_info(`LABEL_NEWPERF, $sformatf(" WRITE LATENCY start time=%0t  end time=%0t latency=%0t txnid,:%0d qos:%0d", q_t_write[tx_wr_idx[0]].timestamp, $realtime, t_latency,txnid,qos), UVM_LOW)
                  write_latency_tools.add_latency_graph_bystepns (t_latency);
                  write_latency_tools.add_latency_graph_bystep   (t_latency);  
		          end
                  wait_wr_lastbeat=1;
          end // end if q_t_write                                
      
      if (tlast) begin 
                  wait_wr_lastbeat=0;
                  q_t_write.delete(tx_wr_idx[0]);   
      end 
       begin:build_bw_graph
	   int nbr_bytes;
       foreach(m_pkt.wstrb[i]) begin
                axi_xstrb_t wstrb =m_pkt.wstrb[i];
				foreach (wstrb[j]) begin
					   	nbr_bytes += wstrb[j]; // i= queue number && j=bit // if bit=1 => 1 bytes
			    end
	   end
          if (doff_nbr_wr_tx <=0) begin
               total_wr_txn++;
               if (total_wr_txn == 1) ev_steady_start_wr_bw.trigger();  // when reach the middle of txn dump all the steady BW
               if (total_wr_txn == ioaiu_num_trans/2) ev_steady_stop_wr_bw.trigger();  // when reach the middle of txn dump all the steady BW
	    				 write_bw_tools.add_bw_perqos(nbr_bytes,qos);
	    				 write_bw_tools.add_bw_graph_bystep(nbr_bytes,tlast);
	    	  end else begin
		      if (tlast) begin:tlast_b
	    		doff_nbr_wr_tx--;
         nbr_bytes=0;
	    	  end:tlast_b
	          end
       end:build_bw_graph

end // end start_sb
endfunction
//******************************************************************************
// Function : write_write_resp_port
//******************************************************************************
function void newperf_test_ace_scb::write_write_resp_port(const ref T_WR m_pkt);
      
      int txnid= m_pkt.bid;
      int tx_wr_idx[$];
      s_txn_cycle lat_cycle; 
       
      if(start_sb)begin
            tx_wr_idx=  q_t_write_resp.find_first_index with (item.txnid == txnid);  
            if (tx_wr_idx.size()>0) begin: _find_write_txnid
                  time t_latency;
                  int c_latency;
                  t_latency = $realtime - q_t_write_resp[tx_wr_idx[0]].timestamp;
                  c_latency = int'(t_latency/period);
                  lat_cycle = '{q_t_write_resp[tx_wr_idx[0]].qos,q_t_write_resp[tx_wr_idx[0]].txnid,c_latency};
    	          if (doff_nbr_wr_tx <=0) begin: _doff_wr_tx
                 `uvm_info(`LABEL_NEWPERF, $sformatf(" WRITE LATENCY start time=%0t  end time=%0t latency=%0t txnid,:%0d", q_t_write_resp[tx_wr_idx[0]].timestamp, $realtime, t_latency,txnid), UVM_LOW)
                  write_resp_latency_tools.add_latency_graph_bystepns (t_latency);
                  write_resp_latency_tools.add_latency_graph_bystep   (t_latency); 
                 end: _doff_wr_tx 
                if(!($test$plusargs("init_all_cache") && (doff_nbr_wr_tx > 0))) begin
                  write_resp_latency_tools.add_latency (lat_cycle);
                end
                 q_t_write_resp.delete(tx_wr_idx[0]);   
          end: _find_write_txnid
        end // end start_sb
endfunction


////////////////////////////////////////////////////////////////////////////////
// Section3:  uvm phase
///////////////////////////////////////////////////////////////////////////////
function void newperf_test_ace_scb::check_phase(uvm_phase phase);
endfunction : check_phase

task newperf_test_ace_scb::run_phase(uvm_phase phase);
    uvm_objection objection;
    
    uvm_event ev_csr_init_done = ev_pool.get("csr_init_done");
    uvm_event ev_report_bw     = ev_pool.get("report_bw");
   
//	case (cfg_e_type) 
//			CHI:ev_linked_scb_end.get($sformatf("ev_ace%0d_scb_end",cfg_aiu_id));
//			ACE:ev_linked_scb_end.get($sformatf("ev_ioaiu%0d_scb_end",cfg_aiu_id));
//			AXI:ev_linked_scb_end.get($sformatf("ev_ioaiu%0d_scb_end",cfg_aiu_id));
//			default:`uvm_fatal(get_full_name(), "CFG_E_TYPE isn't set")
//	endcase

	ev_csr_init_done.wait_trigger();
  start_sb = 1;
  //ev_linked_scb_end.wait_triggger();

  fork
     forever begin
	     ev_report_bw.wait_trigger();
	     report();
     end
     forever begin
      ev_steady_start_rd_bw.wait_trigger();
      read_bw_tools.start_process_steady_bw();
      read_latency_tools.stop_process_steady_lat=0;
      ev_steady_stop_rd_bw.wait_trigger();
      read_bw_tools.stop_process_steady_bw=1;
      read_latency_tools.stop_process_steady_lat=1;
      break;
     end
      forever begin
      ev_steady_start_wr_bw.wait_trigger();
      write_bw_tools.start_process_steady_bw();
      write_latency_tools.stop_process_steady_lat=0;
      ev_steady_stop_wr_bw.wait_trigger();
      write_bw_tools.stop_process_steady_bw=1;
      write_latency_tools.stop_process_steady_lat=1;
      break;
     end
  join_none

endtask : run_phase

function void newperf_test_ace_scb::report_phase(uvm_phase phase);
   report();
endfunction : report_phase

function void newperf_test_ace_scb::report();

  string log_file_path = "perf_metrics.log"; // Define the log file path here
  uvm_report_server svr;

  // Define the log file path
    string log_file_name = "perf_metrics.log";
    int file;

    // Open the file
    file = $fopen(log_file_name, "a");
    if (file == 0) begin
        // Handle error opening file
        $display("Error: Unable to open log file %s for writing.", log_file_name);
        return;
    end

  $fwrite(file, $sformatf("NewPerfTest: ACE Read Min Latency            =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["min"], read_latency_tools.t_latency_req_1stdata["min"]/period));
  $fwrite(file, $sformatf("NewPerfTest: ACE Read Average Latency        =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["average"], read_latency_tools.t_latency_req_1stdata["average"]/period));
  $fwrite(file, $sformatf("NewPerfTest: ACE Read Steady Latency         =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["steady"], read_latency_tools.t_latency_req_1stdata["steady"]/period));
  $fwrite(file, $sformatf("NewPerfTest: ACE Read Max Latency            =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["max"], read_latency_tools.t_latency_req_1stdata["max"]/period));
  
  read_latency_tools.display_latency_graph_bystepns (.file(file));  
  read_latency_tools.display_latency_graph_bystep (.file(file));
  read_latency_tools.display_latency_graph_lasttx (.file(file));
 read_latency_tools.fdisplay_latency("rd");
  
  $fwrite(file,  $sformatf(" ACE Read Min BW                 =  %.2f GB/s\n", read_bw_tools.bw_stats["min"]));
  $fwrite(file,  $sformatf(" ACE Read Average BW             =  %.2f GB/s\n", read_bw_tools.bw_stats["average"]));
  $fwrite(file,  $sformatf(" ACE Read Max BW                 =  %.2f GB/s\n", read_bw_tools.bw_stats["max"]));
  $fwrite(file,  $sformatf(" ACE Read Steady BW              =  %.2f GB/s\n", read_bw_tools.bw_stats["steady"]));

  if (read_bw_tools.bw_stats_qos.size() > 1) begin: _rd_bw_qos
  foreach(read_bw_tools.bw_stats_qos[qos]) begin: _rd_display_bw_perqos
      $fwrite(file, $sformatf(" ACE Read Average BW QOS%0d     =  %.2f GB/s\n", qos,read_bw_tools.bw_stats_qos[qos]["average"]));
      $fwrite(file, $sformatf(" ACE Read Steady BW QOS%0d      =  %.2f GB/s\n", qos,read_bw_tools.bw_stats_qos[qos]["steady"]));
      end: _rd_display_bw_perqos
   end: _rd_bw_qos

  read_bw_tools.display_bw_graph_bystep (.file(file));
  $fwrite(file, "%0s\n", {200{"#"}});

  $fwrite(file,$sformatf(" ACE Write Min Latency           =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["min"], write_latency_tools.t_latency_req_1stdata["min"]/period));
  $fwrite(file,$sformatf(" ACE Write Average Latency       =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["average"], write_latency_tools.t_latency_req_1stdata["average"]/period));
  $fwrite(file,$sformatf(" ACE Write Steady Latency        =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["steady"], write_latency_tools.t_latency_req_1stdata["steady"]/period));
  $fwrite(file,$sformatf(" ACE Write Max Latency           =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["max"], write_latency_tools.t_latency_req_1stdata["max"]/period));
  
  write_latency_tools.display_latency_graph_bystepns (.file(file));  
  write_latency_tools.display_latency_graph_bystep (.file(file));
  write_latency_tools.display_latency_graph_lasttx (.file(file));
  write_latency_tools.fdisplay_latency ("wr");
  $fwrite(file, "%0s\n", {200{"#"}});

  $fwrite(file, $sformatf(" ACE Write Resp Min Latency      =  %.2t, %0d cycles\n", write_resp_latency_tools.t_latency_req_1stdata["min"], write_resp_latency_tools.t_latency_req_1stdata["min"]/period));
  $fwrite(file, $sformatf(" ACE Write Resp Average Latency  =  %.2t, %0d cycles\n", write_resp_latency_tools.t_latency_req_1stdata["average"], write_resp_latency_tools.t_latency_req_1stdata["average"]/period));
  $fwrite(file, $sformatf(" ACE Write Resp Steady Latency   =  %.2t, %0d cycles\n", write_resp_latency_tools.t_latency_req_1stdata["steady"], write_resp_latency_tools.t_latency_req_1stdata["steady"]/period));
  $fwrite(file, $sformatf(" ACE Write Resp Max Latency      =  %.2t, %0d cycles\n", write_resp_latency_tools.t_latency_req_1stdata["max"], write_resp_latency_tools.t_latency_req_1stdata["max"]/period));
  
  write_resp_latency_tools.display_latency_graph_bystepns (.file(file));  
  write_resp_latency_tools.display_latency_graph_bystep (.file(file));
  write_resp_latency_tools.display_latency_graph_lasttx (.file(file));
  //write_resp_latency_tools.fdisplay_latency("wr_resp");

  $fwrite(file, $sformatf(" ACE Write Min BW                =  %.2f GB/s\n", write_bw_tools.bw_stats["min"]));
  $fwrite(file, $sformatf(" ACE Write Average BW            =  %.2f GB/s\n", write_bw_tools.bw_stats["average"]));
  $fwrite(file, $sformatf(" ACE Write Max BW                =  %.2f GB/s\n", write_bw_tools.bw_stats["max"]));
  $fwrite(file, $sformatf(" ACE Write Steady BW             =  %.2f GB/s\n", write_bw_tools.bw_stats["steady"]));
  if (write_bw_tools.bw_stats_qos.size() > 1) begin: _wr_bw_qos
    foreach(write_bw_tools.bw_stats_qos[qos]) begin: _wr_display_bw_perqos
        $fwrite(file, $sformatf(" ACE Write Average BW QOS%0d     =  %.2f GB/s\n", qos,write_bw_tools.bw_stats_qos[qos]["average"]));
        $fwrite(file, $sformatf(" ACE Write Steady BW QOS%0d      =  %.2f GB/s\n", qos,write_bw_tools.bw_stats_qos[qos]["steady"]));
        end: _wr_display_bw_perqos
     end: _wr_bw_qos
  
 write_bw_tools.display_bw_graph_bystep (.file(file));
   $fwrite(file, "%0s\n", {200{"#"}});
  
   $fclose(file);
endfunction : report
