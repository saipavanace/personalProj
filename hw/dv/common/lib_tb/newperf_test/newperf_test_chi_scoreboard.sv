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

`uvm_analysis_imp_decl ( _req_port     )
`uvm_analysis_imp_decl ( _rdata_port   )
`uvm_analysis_imp_decl ( _wdata_port   )
`uvm_analysis_imp_decl ( _crsp_port   )

////////////////////////////////////////////////////////////////////////////////
// Section1:  Scoreboard top
//
//
////////////////////////////////////////////////////////////////////////////////

class newperf_test_chi_scb #(parameter type T_REQ = chi_req_seq_item
              				      ,parameter type T_DATA = chi_dat_seq_item
        			              ,parameter type T_RSP = chi_rsp_seq_item
             ) extends uvm_scoreboard;
             
  `uvm_component_param_utils(newperf_test_chi_scb#(T_REQ,T_DATA,T_RSP))
 
	/////////////////////////////////////////
	// CFG Attribut of configuration       //
	/////////////////////////////////////////
    // Type CHI,ACE etc...
	e_pt_type_itf  cfg_e_type = newperf_test_tools_pkg::NONE;  // Must BE CHI,ACE. With NONE scb doesn't work
	int cfg_aiu_id = -1; 
  string aiu_name;
	//verbosity
	bit cfg_b_display_latency_graph = 1'b1;

	// END CFG //
	////////////

    ///////////////////////
	// Ports             //
    uvm_analysis_imp_req_port     #(
      T_REQ, newperf_test_chi_scb) req_port;
    uvm_analysis_imp_rdata_port   #(
      T_DATA, newperf_test_chi_scb) rdata_port;
    uvm_analysis_imp_wdata_port   #(
      T_DATA, newperf_test_chi_scb) wdata_port;
    uvm_analysis_imp_crsp_port   #(
      T_RSP, newperf_test_chi_scb) crsp_port;
//    uvm_analysis_imp_wdata_port   #(
//      T_DATA, newperf_test_chi_scb) wdata_port;
 

    // event global pool
    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_steady_start_rd_bw = ev_pool.get("ev_steady_start_rd_bw");
    uvm_event ev_steady_stop_rd_bw = ev_pool.get("ev_steady_stop_rd_bw");
    uvm_event ev_steady_start_wr_bw = ev_pool.get("ev_steady_start_wr_bw");
    uvm_event ev_steady_stop_wr_bw = ev_pool.get("ev_steady_stop_wr_bw");

   int chi_num_trans;    
   int total_rd_txn;
   int total_wr_txn;

	// scoreboard attribut
	bit start_sb;

  // REMOVE FIRST TXN
	int doff_nbr_rd_tx; // remove the x first read transactions // 
	int doff_nbr_wr_tx; // remove the x first writetransactions // 

    // latency Attributs use by tools function cf below
    s_txn_timestamp q_t_req[$]; // time of the request for each int=txnid
    newperf_test_latency_tools read_latency_tools;
    newperf_test_latency_tools write_latency_tools;
    newperf_test_bw_tools read_bw_tools;
    newperf_test_bw_tools write_bw_tools;
    newperf_test_bw_tools write_snp_bw_tools;
    bit wait_rd_lastbeat=1;

    real  frequency;
    time  period;

    // UVM task & function
    extern function new(string name="newperf_test_chi_scb", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
   
    //check phase
    extern function void check_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);

    //Write Function for CHI port
    extern function void write_req_port     ( const ref T_REQ  m_pkt ) ;
    extern function void write_rdata_port   ( const ref T_DATA m_pkt ) ;
    extern function void write_wdata_port   ( const ref T_DATA m_pkt ) ;
    extern function void write_crsp_port   ( const ref T_RSP m_pkt ) ;
    //extern function void newperf_testchi_wdata_port   ( const ref T_DATA m_pkt ) ;
    extern function void report();

endclass

////////////////////////////////////////////////////////////////////////////////
// Section1:  UVM INIT TASK & FUNCTION
///////////////////////////////////////////////////////////////////////////////

//Constructor
function newperf_test_chi_scb::new(string name="newperf_test_chi_scb", uvm_component parent=null);
    super.new(name,parent);
     if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
endfunction

//Build phase
function void newperf_test_chi_scb::build_phase(uvm_phase phase);
    
    //CHI Ports
    req_port           = new("req_port"     , this);
    rdata_port         = new("rdata_port"   , this);
    wdata_port         = new("wdata_port"   , this);
    crsp_port          = new("crsp_port"    , this);
    read_latency_tools  = new("READ  REQ -> 1stDATA latency",cfg_e_type,cfg_aiu_id,aiu_name);
    write_latency_tools = new("WRITE REQ -> COMP    latency",cfg_e_type,cfg_aiu_id,aiu_name);
    read_bw_tools  = new("READ_BW  ",cfg_e_type,cfg_aiu_id,aiu_name);
    write_bw_tools = new("WRITE_BW ",cfg_e_type,cfg_aiu_id,aiu_name);
    write_snp_bw_tools = new("WRITE_BW_SNP ",cfg_e_type,cfg_aiu_id,aiu_name);
	
    if (cfg_aiu_id == -1) `uvm_fatal(`LABEL_NEWPERF, "CFG_AIU_ID isn't set")
    if (frequency == 0) `uvm_fatal(`LABEL_NEWPERF, "AIU Frequency isn't set")

    period = ((1/frequency) * 1000000) * 1ns;
 
endfunction

////////////////////////////////////////////////////////////////////////////////
// Section2:  UVM Write PORTs functions
////////////////////////////////////////////////////////////////////////////////
//******************************************************************************
// Function : write_req_port
//******************************************************************************
function void newperf_test_chi_scb::write_req_port(const ref T_REQ m_pkt);
    
  int txnid=m_pkt.txnid;
  int qos = m_pkt.qos;
  string str_opcode=m_pkt.opcode.name();

        if(start_sb)begin: _start_sb
        `uvm_info(`LABEL_NEWPERF, $psprintf("write_req_port. Pkt=%0s", m_pkt.convert2string()), UVM_MEDIUM)
            if (!uvm_re_match(uvm_glob_to_re("*READ*"),str_opcode)    //CHI 
             || !uvm_re_match(uvm_glob_to_re("*WRITE*"),str_opcode )  //CHI
                 ) begin // only Read or Write opcode type
              q_t_req.push_back('{qos,txnid,$realtime}); 
              `uvm_info(`LABEL_NEWPERF, $sformatf("CAPTURE REQUEST start time=%0t txndi:%0d qos:%0d", $realtime, txnid,qos), UVM_LOW)
            end
      end:_start_sb 
endfunction

//******************************************************************************
// Function : write_rdata_port
//******************************************************************************
function void newperf_test_chi_scb::write_rdata_port(const ref T_DATA m_pkt);
      
      int txnid=m_pkt.txnid;
      int tx_rd_idx[$];
      s_txn_cycle lat_cycle; 
      int qos;
      string str_opcode=m_pkt.opcode.name();
      bit tlast = (WDATA == 128)? (m_pkt.dataid == 'h3) : (WDATA==256) ? (m_pkt.dataid == 'h2) : 1; 
      if(start_sb)begin: _start_sb
    
     //NewPerfTest: process read latency by TXnID
        tx_rd_idx=  q_t_req.find_first_index with (item.txnid == txnid);  
        if (tx_rd_idx.size()>0) qos=q_t_req[tx_rd_idx[0]].qos;
          if (tlast)begin:_tlast_rd
              wait_rd_lastbeat=0;
            end:_tlast_rd
        if(!uvm_re_match(uvm_glob_to_re("*DATA*"),str_opcode)) begin: _opcode_data // Data Opcode type reminder uvm_re_match =0  when match
            if (tx_rd_idx.size()>0 && tlast==1) begin: _find_txnid 
                  time t_latency;
                  int  c_latency;
                  time start_time = q_t_req[tx_rd_idx[0]].timestamp;
                  t_latency = $realtime - start_time;
                  c_latency = int'(t_latency/period);
                  lat_cycle = '{q_t_req[tx_rd_idx[0]].qos,q_t_req[tx_rd_idx[0]].txnid,c_latency};
				      if (doff_nbr_rd_tx <=0) begin: _doff_rd
                     `uvm_info(`LABEL_NEWPERF, $sformatf("READ LATENCY opcode: %0s start time=%0t  end time=%0t latency=%0t txnid:%0d", str_opcode,start_time, $realtime, t_latency,txnid), UVM_LOW)
				             read_latency_tools.add_latency_graph_bystepns (t_latency);
                     read_latency_tools.add_latency_graph_bystep   (t_latency);  
              end: _doff_rd
              read_latency_tools.add_latency (lat_cycle);
              wait_rd_lastbeat=1;
            end: _find_txnid
        
            if (tlast)begin:_tlast_rd
              q_t_req.delete(tx_rd_idx[0]);   
            
            end:_tlast_rd
        end: _opcode_data
          
        // process read BW 
         if(!uvm_re_match(uvm_glob_to_re("*DATA*"),str_opcode)) begin:_opcode_bw // Data Opcode type reminder uvm_re_match =0  when match
               int nbr_bytes = WDATA /8;
			   if (doff_nbr_rd_tx <=0) begin:_doff_rd_bw
               `uvm_info(`LABEL_NEWPERF, $sformatf("READ BW opcode: %0s time=%0t txnid:%0d", str_opcode,$realtime,txnid), UVM_LOW)
                total_rd_txn++;
                if (total_rd_txn == 1) ev_steady_start_rd_bw.trigger();  // when reach the middle of txn dump all the steady BW          
                if (total_rd_txn == chi_num_trans/2) begin
                      ev_steady_stop_rd_bw.trigger();  // when reach the middle of txn dump all the steady BW          
                 end
                read_bw_tools.add_bw_perqos(nbr_bytes,qos);
                read_bw_tools.add_bw_graph_bystep(nbr_bytes,tlast);
                 end: _doff_rd_bw else begin 
				           if(tlast) begin:_tlast_b
				            doff_nbr_rd_tx--;
                               `uvm_info(`LABEL_NEWPERF, $sformatf("DOFF READ TXN opcode: %0s time=%0t txnid:%0d", str_opcode, $realtime,txnid), UVM_LOW)
                  
				            end:_tlast_b
	      		 end
        end:_opcode_bw

        end:_start_sb
endfunction
//******************************************************************************
// Function : write_wdata_port
//******************************************************************************
function void newperf_test_chi_scb::write_wdata_port(const ref T_DATA m_pkt);
      
  int txnid=m_pkt.txnid;
  string str_opcode=m_pkt.opcode.name();
  int tx_rd_idx[$];
  int qos;
  bit tlast = (WDATA == 128)? (m_pkt.dataid == 'h3) : (WDATA==256) ? (m_pkt.dataid == 'h2) : 1; 
  
  if(start_sb)begin
     int nbr_bytes= WDATA/8;
     `uvm_info(`LABEL_NEWPERF, $sformatf("WRITE BW opcode: %0s time=%0t", str_opcode,$realtime), UVM_LOW)
     tx_rd_idx=  q_t_req.find_first_index with (item.txnid == txnid);  
     if (tx_rd_idx.size()>0) qos=q_t_req[tx_rd_idx[0]].qos;
    // process write BW 
     if(!uvm_re_match(uvm_glob_to_re("*WRDATA"),str_opcode)) begin // Data Opcode type reminder uvm_re_match =0  when match
            if (doff_nbr_wr_tx <=0) begin
                total_wr_txn++;
                if (total_wr_txn == 1) ev_steady_start_wr_bw.trigger();           
                if (total_wr_txn == chi_num_trans/2) ev_steady_stop_wr_bw.trigger();  // when reach the middle of txn dump all the steady BW   
                write_bw_tools.add_bw_perqos(nbr_bytes,qos);
                write_bw_tools.add_bw_graph_bystep(nbr_bytes,tlast);
	     	 end else begin
				 if(tlast) begin:tlast_b
                    
					 doff_nbr_wr_tx--;
				end:tlast_b
             end 
     end

	 if(!uvm_re_match(uvm_glob_to_re("*SNPRESPDATA*"),str_opcode)) begin // SNP Data Opcode type reminder uvm_re_match =0  when match
          write_snp_bw_tools.add_bw_graph_bystep(nbr_bytes,tlast);
     end

    end // end start_sb
endfunction
//******************************************************************************
// Function : write_crsp_port
//******************************************************************************
function void newperf_test_chi_scb::write_crsp_port(const ref T_RSP m_pkt);
      
  int txnid=m_pkt.txnid;
  string str_opcode=m_pkt.opcode.name;
  int tx_wr_idx[$];
  s_txn_cycle lat_cycle; 

  if (start_sb) begin: _start_sb

 //NewPerfTest: process read latency by TXnID
    tx_wr_idx=  q_t_req.find_first_index with (item.txnid == txnid);  
    if (tx_wr_idx.size()>0) begin: _find_txnid 
            if(!uvm_re_match(uvm_glob_to_re("*COMP*"),str_opcode)) begin:_opcode_comp // Data Opcode type reminder uvm_re_match =0  when match
              time t_latency;
              int c_latency;
              t_latency = $realtime - q_t_req[tx_wr_idx[0]].timestamp;
              c_latency = int'(t_latency/period);
              lat_cycle = '{q_t_req[tx_wr_idx[0]].qos,q_t_req[tx_wr_idx[0]].txnid,c_latency};
              if (doff_nbr_wr_tx <=0) begin: _doff_wr_tx
                 `uvm_info(`LABEL_NEWPERF, $sformatf("WRITE LATENCY start time=%0t  end time=%0t latency=%0t txnid,:%0d qos:%0d", q_t_req[tx_wr_idx[0]].timestamp, $realtime, t_latency,txnid,q_t_req[tx_wr_idx[0]].qos), UVM_LOW)
                  write_latency_tools.add_latency_graph_bystepns (t_latency);
                  write_latency_tools.add_latency_graph_bystep   (t_latency); 
              end: _doff_wr_tx else begin
                    `uvm_info(`LABEL_NEWPERF, $sformatf("DOFF WRITE CRSP start time=%0t  end time=%0t latency=%0t txnid,:%0d qos:%0d", q_t_req[tx_wr_idx[0]].timestamp, $realtime, t_latency,txnid,q_t_req[tx_wr_idx[0]].qos), UVM_LOW)
              end
              if(!($test$plusargs("init_all_cache") && (doff_nbr_wr_tx > 0))) begin
                write_latency_tools.add_latency (lat_cycle);
              end
              q_t_req.delete(tx_wr_idx[0]);   
            end: _opcode_comp
      end: _find_txnid                                
    end: _start_sb // end start_sb
endfunction
////////////////////////////////////////////////////////////////////////////////
// Section3:  uvm phase
///////////////////////////////////////////////////////////////////////////////
function void newperf_test_chi_scb::check_phase(uvm_phase phase);
endfunction : check_phase

task newperf_test_chi_scb::run_phase(uvm_phase phase);
    uvm_objection objection;
    
    uvm_event ev_csr_init_done = ev_pool.get("csr_init_done");
    uvm_event ev_report_bw     = ev_pool.get("report_bw");

    ev_csr_init_done.wait_trigger();
    start_sb = 1;

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

function void newperf_test_chi_scb::report_phase(uvm_phase phase);
   report();
endfunction : report_phase

function void newperf_test_chi_scb::report();
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

   $fwrite(file, $sformatf("CHI Read Min Latency        =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["min"], read_latency_tools.t_latency_req_1stdata["min"]/period));
   $fwrite(file, $sformatf("CHI Read Average Latency    =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["average"], read_latency_tools.t_latency_req_1stdata["average"]/period));
   $fwrite(file, $sformatf("CHI Read Steady Latency     =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["steady"], read_latency_tools.t_latency_req_1stdata["steady"]/period));
   $fwrite(file, $sformatf("CHI Read Max Latency        =  %.2t, %0d cycles\n", read_latency_tools.t_latency_req_1stdata["max"], read_latency_tools.t_latency_req_1stdata["max"]/period));
  
  read_latency_tools.display_latency_graph_bystepns (.file(file));  
  read_latency_tools.display_latency_graph_bystep (.file(file));
  read_latency_tools.display_latency_graph_lasttx (.file(file));
  read_latency_tools.fdisplay_latency ("rd");

  $fwrite(file, $sformatf("CHI Read Min BW             =  %.2f GB/s\n", read_bw_tools.bw_stats["min"]));
  $fwrite(file, $sformatf("CHI Read Average BW         =  %.2f GB/s\n", read_bw_tools.bw_stats["average"]));
  $fwrite(file, $sformatf("CHI Read Max BW             =  %.2f GB/s\n", read_bw_tools.bw_stats["max"]));
  $fwrite(file,$sformatf("CHI Read Steady BW           =  %.2f GB/s\n", read_bw_tools.bw_stats["steady"]));
  if (read_bw_tools.bw_stats_qos.size() > 1) begin: _rd_bw_qos
    foreach(read_bw_tools.bw_stats_qos[qos]) begin: _rd_display_bw_perqos
       $fwrite(file, $sformatf(" CHI Read Average BW QOS%0d     =  %.2f GB/s\n", qos,read_bw_tools.bw_stats_qos[qos]["average"]));
       $fwrite(file, $sformatf(" CHI Read Steady BW QOS%0d      =  %.2f GB/s\n", qos,read_bw_tools.bw_stats_qos[qos]["steady"]));
        end: _rd_display_bw_perqos
     end: _rd_bw_qos
  read_bw_tools.display_bw_graph_bystep (.file(file));
  $fwrite(file,"%0s",{200{"#"}});

 $fwrite(file, $sformatf("CHI Write Min Latency       =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["min"], write_latency_tools.t_latency_req_1stdata["min"]/period));
 $fwrite(file, $sformatf("CHI Write Average Latency   =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["average"], write_latency_tools.t_latency_req_1stdata["average"]/period));
 $fwrite(file, $sformatf("CHI Write Steady Latenc y   =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["steady"], write_latency_tools.t_latency_req_1stdata["steady"]/period));
 $fwrite(file, $sformatf("CHI Write Max Latency       =  %.2t, %0d cycles\n", write_latency_tools.t_latency_req_1stdata["max"], write_latency_tools.t_latency_req_1stdata["max"]/period));
  
  write_latency_tools.display_latency_graph_bystepns (.file(file));  
  write_latency_tools.display_latency_graph_bystep (.file(file));
  write_latency_tools.display_latency_graph_lasttx (.file(file));
  write_latency_tools.fdisplay_latency ("wr");

 $fwrite(file, $sformatf("CHI Write Min BW            =  %.2f GB/s\n", write_bw_tools.bw_stats["min"]));
 $fwrite(file, $sformatf("CHI Write Average BW        =  %.2f GB/s\n", write_bw_tools.bw_stats["average"]));
 $fwrite(file, $sformatf("CHI Write Steady BW         =  %.2f GB/s\n", write_bw_tools.bw_stats["steady"]));
 $fwrite(file, $sformatf("CHI Write Max BW            =  %.2f GB/s\n", write_bw_tools.bw_stats["max"]));
  if (write_bw_tools.bw_stats_qos.size() > 1) begin: _wr_bw_qos
    foreach(write_bw_tools.bw_stats_qos[qos]) begin: _wr_display_bw_perqos
       $fwrite(file, $sformatf(" CHI Write Average BW QOS%0d     =  %.2f GB/s\n", qos,write_bw_tools.bw_stats_qos[qos]["average"]));
       $fwrite(file, $sformatf(" CHI Write Steady BW QOS%0d      =  %.2f GB/s\n", qos,write_bw_tools.bw_stats_qos[qos]["steady"]));
        end: _wr_display_bw_perqos
     end: _wr_bw_qos
  write_bw_tools.display_bw_graph_bystep (.file(file));

 $fwrite(file, $sformatf("CHI Snoop Write Min BW      =  %.2f GB/s\n", write_snp_bw_tools.bw_stats["min"]));
 $fwrite(file, $sformatf("CHI Snoop Write Average BW  =  %.2f GB/s\n", write_snp_bw_tools.bw_stats["average"]));
 $fwrite(file, $sformatf("CHI Snoop Write Steady BW   =  %.2f GB/s\n", write_snp_bw_tools.bw_stats["steady"]));
 $fwrite(file, $sformatf("CHI Snoop Write Max BW      =  %.2f GB/s\n", write_snp_bw_tools.bw_stats["max"]));
  write_snp_bw_tools.display_bw_graph_bystep (.file(file));

  $fwrite(file,"%0s",{200{"#"}});
  
endfunction : report
