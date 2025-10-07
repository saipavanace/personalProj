////////////////////////////////////////////////////////////////////////////////
//
// Author       : Cyrille LUDWIG
// Purpose      : TOOLS FUNCTION use by the newperf_test scoreboard
// Revision     :
//                  Use with plusargs "+newperf_test_scb"
//
////////////////////////////////////////////////////////////////////////////////

class newperf_test_bw_tools;
             
	/////////////////////////////////////////
  // Type CHI,ACE etc...
	e_pt_type_itf  cfg_e_type = NONE;  // Must BE CHI,ACE. With NONE scb doesn't work
	int cfg_aiu_id = -1; 
  string cfg_tab_name;
  string aiu_name;

	//Latency graph
	int  cfg_step=200;  // nbr of transaction to calculate the BW

	//verbosity
	bit cfg_b_display_bw_graph = 1'b1;

	// END CFG //
	////////////
    
    // bw Attributs use by tools function cf below
    int  bw_nbr_received; // use to calculate the average
    real bw_stats[string];  //string = min,max,average,steady_bw 
    real bw_stats_qos[int][string];  //int=qos string = average,steady_bw 
    int  bw_total_bytes_bystep[int]; // total of bytes to calculate the average by step of <cfg_step> transactions
    int  bw_total_bytes; // total of bytes to calculate the GLOBAL average
    int  bw_total_bytes_qos[int]; // total of bytes to calculate the GLOBAL average per qos
    int  tx_nbr;  //tx_nbr modulo cfg_step use by bw_tx_nbr
    int  tx_nbr_qos[int];  //tx_nbr per qos
    real bw_average_bystep[int]; // bw average by step of cfg_step transactions
    int  tx_step_nbr; // nbr of step (by step of cfg_step) use by bw_average_tx_step
    realtime q_bw_lasttx[$];  //queue with max size = cfg_step // store the cft_step last transaction
    realtime t_step_end;
    realtime t_step_start;
    realtime t_start;
    realtime t_start_steady_bw;
    realtime t_start_qos[int]; //start  timestamp per qos=int
    
   
    bit stop_process_steady_bw=1;

    //Constructor
    function new(string m_name, e_pt_type_itf m_e_type, int aiu_id, string aiu_name="");
            cfg_e_type= m_e_type;
            cfg_aiu_id =aiu_id;
            cfg_tab_name=m_name;
            this.aiu_name=aiu_name;
    endfunction
 
    //tools function
    extern function void start_process_steady_bw();  
    extern function void add_bw_graph_bystep  ( const ref int m_nbr_bytes  
                                                  ,bit tlast
                                                    ,int m_step= cfg_step
                                                   );
   extern function void add_bw_perqos  ( const ref int m_nbr_bytes  
                                                   ,int qos
                                                    );
    extern function void display_bw_graph_bystep ( string m_tab_name=cfg_tab_name 
                                                       ,int m_step=cfg_step
                                                       ,int file
                                                      ); 
endclass

////////////////////////////////////////////////////////////////////////////////
// Section4:  tools function
///////////////////////////////////////////////////////////////////////////////
function void newperf_test_bw_tools::start_process_steady_bw();
   t_start_steady_bw = $realtime;
   stop_process_steady_bw =0;
endfunction:start_process_steady_bw 

function void newperf_test_bw_tools::add_bw_graph_bystep  ( 
                                                                        const ref int m_nbr_bytes 
                                                                       ,bit tlast 	
                                                                       ,int m_step
);
// process average by step of cfg_step and max average by step to add to the graph
case (tx_nbr) 
 //CASE first TXN of the step
  0: begin:first_bytes
     bw_total_bytes_bystep[tx_step_nbr] =m_nbr_bytes;
	 if (tx_step_nbr ==0 ) begin // first step 
		    t_step_start = $realtime; // only for the first <m_step_>tx after init on last_bytes for the other step
        bw_total_bytes =m_nbr_bytes;
	      t_start = $realtime; 
	  end
     tx_nbr++;
      end:first_bytes
 // CASE LAST TXN 	  
  m_step-1 : begin:last_bytes
               bw_total_bytes_bystep[tx_step_nbr] = bw_total_bytes_bystep[tx_step_nbr] + m_nbr_bytes;
               bw_total_bytes = bw_total_bytes + m_nbr_bytes;
               t_step_end = $realtime;
               bw_average_bystep[tx_step_nbr] = real'(bw_total_bytes_bystep[tx_step_nbr])/ (real'(t_step_end -t_step_start)/1000);
               bw_stats["average"]=real'(bw_total_bytes)/ (real'(t_step_end - t_start)/1000);
               if (!stop_process_steady_bw) bw_stats["steady"]=real'(bw_total_bytes)/ (real'(t_step_end - t_start_steady_bw)/1000);;
              //$display ("CLUDEBUG_BW TOTAL BYTES: %0d t:%0t %0.2f",bw_total_bytes_bystep[tx_step_nbr],t_step_end-t_step_start,real'(t_step_end -t_step_start)/1000);
              
			   if (tlast) begin:tlast_b
               begin:min_max_bw
                real bw = bw_average_bystep[tx_step_nbr];
                this.bw_nbr_received++;
                // process min bw
                if (!bw_stats.exists("min") || bw < bw_stats["min"]) begin
                  bw_stats["min"] = bw;
                  //$display ("CLUDEBUG_BW MIN:%.2f GB/s",bw);
                end
                // process max bw
                if (!bw_stats.exists("max") || bw > bw_stats["max"]) begin
                  bw_stats["max"] = bw;
                  //$display ("CLUDEBUG_BW MAX:%.2f GB/s",bw);
                end
              end: min_max_bw  

               //$display("NEWCLUDEBUG_BW: step:%0d average:%.2f, max:%.f, perc:%0d",tx_step_nbr,bw_average_bystep[tx_step_nbr], bw_stats["max"], int'(100*bw_average_bystep[tx_step_nbr]/bw_stats["max"]));
			        tx_step_nbr++;
    	        tx_nbr =0;
               bw_total_bytes_bystep.delete(); // free space
               t_step_start = $realtime;
        	   end:tlast_b
              end: last_bytes
  // CASE m_step-1<TXN<0
  default: begin
    bw_total_bytes_bystep[tx_step_nbr] = bw_total_bytes_bystep[tx_step_nbr] + m_nbr_bytes;
    bw_total_bytes = bw_total_bytes + m_nbr_bytes;
    t_step_end = $realtime;
    bw_average_bystep[tx_step_nbr] = real'(bw_total_bytes_bystep[tx_step_nbr])/ (real'(t_step_end -t_step_start)/1000); //overwrite last BW for this step
    bw_stats["average"]=real'(bw_total_bytes)/ (real'(t_step_end -t_start)/1000);
    if (!stop_process_steady_bw) begin
              bw_stats["steady"]=real'(bw_total_bytes)/ (real'(t_step_end - t_start_steady_bw)/1000);;
    end
    if (tlast) tx_nbr++;
    end
endcase	
endfunction:add_bw_graph_bystep

function void newperf_test_bw_tools::add_bw_perqos  ( 
  const ref int m_nbr_bytes 
 ,int qos
);
    if (!tx_nbr_qos.exists(qos)) begin: _qos_start
            bw_total_bytes_qos[qos] = m_nbr_bytes;
	          t_start_qos[qos] = $realtime; 
    end:_qos_start
    else begin: _qos_nxt_byte
         bw_total_bytes_qos[qos] = bw_total_bytes_qos[qos] + m_nbr_bytes;
         bw_stats_qos[qos]["average"]=real'(bw_total_bytes_qos[qos])/ (real'($realtime - t_start_qos[qos])/1000);
         if (!stop_process_steady_bw) bw_stats_qos[qos]["steady"]=bw_stats_qos[qos]["average"];
    end: _qos_nxt_byte
    tx_nbr_qos[qos]++;

endfunction:add_bw_perqos

function void newperf_test_bw_tools::display_bw_graph_bystep (
                                                                          string m_tab_name 
                                                                         ,int m_step
                                                                         ,int file
                                                                       );
  string str_average_line=`LABEL_NEWPERF;
  int max_step= bw_average_bystep.size();
  str_average_line= $sformatf("%0s %0s average by %0d transactions step=",str_average_line, m_tab_name,m_step); //nbr of case on one line
  if (file == 0) begin
     $display("Error: Invalid file handle.");
        return;
  end
  $fwrite(file,"%0s\n",{200{"="}});
  $fwrite(file,`LABEL_NEWPERF);
  $fwrite(file,"%0s bw table\n",m_tab_name);
  $fwrite(file,"%0d transactions\n",(this.bw_nbr_received*m_step) + this.tx_nbr-1);
  if (max_step==0) begin
    $fwrite(file,"!!!!!! Warning no Graph because no data !!!!!!\n");
 end else begin
  $fwrite(file,"| %30s | %10s | %10s | graph\n","step", "BW", "N/A");
  for (int i=0;i <max_step;i++) begin:for_eachstep
    int percentage= (bw_stats["max"] != 0.0) ? int'(100*bw_average_bystep[i]/bw_stats["max"]) : 100;
    str_average_line = $sformatf("%0s,%.2f",str_average_line,bw_average_bystep[i]);
    $fwrite (file,"| %30s | %10.2f | %10d |", $sformatf("%0d<transactions<%0d",i*m_step,m_step*(i+1)),bw_average_bystep[i],"");
    for (int p=0;p<percentage;p++) begin
      $fwrite (file,"*");
    end
    $fwrite(file,"\n"); // newline
  end:for_eachstep
  $fwrite(file,"%0s\n",str_average_line);
end // end max_step >0
  $fwrite(file,"%0s\n",{200{"-"}});
endfunction: display_bw_graph_bystep
