////////////////////////////////////////////////////////////////////////////////
//
// Author       : Cyrille LUDWIG
// Purpose      : TOOLS FUNCTION use by the newperf_test scoreboard
// Revision     :
//                  Use with plusargs "+newperf_test"
//
////////////////////////////////////////////////////////////////////////////////

class newperf_test_latency_tools;
             
	/////////////////////////////////////////
  // Type CHI,ACE etc...
	e_pt_type_itf  cfg_e_type = NONE;  // Must BE CHI,ACE. With NONE scb doesn't work
	int cfg_aiu_id = -1; 
  string aiu_name ;
  string cfg_tab_name;

	//Latency graph
	time cfg_t_step=25ns; // step per ns
	int  cfg_c_step=25;  // step per cycle
  int  cfg_c_max =2500; // max value of the graphs before display as "> cfg_c_max"
  time cfg_t_max =2000ns; // max value of the graphs before display as "> cfg_t_max"
  int  cfg_step=50;  // calculate the average each <cfg_step> nbr of transaction 
  
	//verbosity
	bit cfg_b_display_latency_graph = 1'b1;

	// END CFG //
	////////////

    // latency Attributs use by tools function cf below
    int  latency_nbr_received; // use to calculate the average  
    int  latency_steady_nbr_received; // use to calculate the steady latency  
    int  all_latency_nbr_received[int]; // use to calculate the average per int=qos
    int  all_latency_steady_nbr_received[int]; // use to calculate the average per int=qos
    time t_latency_req_1stdata[string];  //string = min,max,average,steady  latency on the first beat data 
    int  nbr_latency_bystepns[string];
    time t_latency_total_bystep[int]; // total to calculate the average by step of cfg_step transactions
    int  tx_nbr;  //tx_nbr moduo cfg_step use by t_latency_tx_nbr
    time t_latency_average_bystep[int]; // latency average by step of cfg_step transactions
    time t_latency_average_max_bystep=0ns; // max latency average by step of cfg_step transactions to add a graph
    int  tx_step_nbr; // nbr of step (by step of cfg_step) use by t_latency_average_tx_step
    time q_t_latency_lasttx[$];  //queue with max size = cfg_step // store the cft_step last transaction
    s_txn_cycle q_latency_steady_tx[$];  //queue of steady transaction latencies // steady means when all the SELECTED agent are still sending txn
    int latency_req_qos_1stdata[int][string];  //int:qos  & string = min,max,average latency on the first beat data 
    int  nbr_latency_bystepcycle[int][string]; //int:cycle string:cycle
    
    bit stop_process_steady_lat=1;
    
    //Constructor
    function new(string m_name, e_pt_type_itf m_e_type, int aiu_id,string m_aiu_name="");
            cfg_e_type= m_e_type;
            cfg_aiu_id =aiu_id;
            cfg_tab_name=m_name;
            aiu_name = m_aiu_name;
    endfunction
 
    //tools function
    extern function void add_latency_graph_bystepns ( const ref time m_t_latency 
                                                     ,time m_t_step= cfg_t_step
                                                     ,time m_t_max = cfg_t_max
                                                    );
    extern function void add_latency_graph_bystep  ( const ref time m_t_latency  
                                                    ,int m_step= cfg_step
                                                   );
     extern function void add_latency  ( const ref s_txn_cycle m_latency
                                         ,int m_c_step = cfg_c_step 
                                         ,int m_c_max  = cfg_c_max 
    );

   extern function void display_latency_graph_bystepns ( string m_tab_name=cfg_tab_name 
                                                        ,time m_t_step=cfg_t_step
                                                        ,time m_t_max=cfg_t_max
                                                        ,int file
                                                      );   
    extern function void display_latency_graph_bystep ( string m_tab_name=cfg_tab_name 
                                                       ,int m_step=cfg_step
                                                       ,int file
                                                       
                                                      );  
    extern function void display_latency_graph_lasttx (
                                                        string m_tab_name =cfg_tab_name
                                                        ,int m_step=cfg_step
                                                        ,int file
                                                     
                                                        );    
    extern function void fdisplay_latency ( string m_tab_name =cfg_tab_name
                                           ,int m_c_step = cfg_c_step 
                                           ,int m_c_max=cfg_c_max
                                                          );                                                                                                                                                                                                         
endclass

////////////////////////////////////////////////////////////////////////////////
// Section4:  tools function
///////////////////////////////////////////////////////////////////////////////
function void newperf_test_latency_tools::add_latency_graph_bystepns (
                                        const ref time m_t_latency
                                        ,time m_t_step
                                        ,time m_t_max
  );
 begin:min_max_average_latency
  latency_nbr_received++;
  if(!stop_process_steady_lat)latency_steady_nbr_received++;
  // process min latency
  if (!t_latency_req_1stdata.exists("min") || m_t_latency < t_latency_req_1stdata["min"]) begin
    t_latency_req_1stdata["min"] = m_t_latency;
   // $display ("CLUDEBUG_SCB3 MIN: t=%0t",m_t_latency);
  end
  // process min latency
  if (!t_latency_req_1stdata.exists("max") || m_t_latency > t_latency_req_1stdata["max"]) begin
    t_latency_req_1stdata["max"] = m_t_latency;
    //$display ("CLUDEBUG_SCB3 MAX: t=%0t",m_t_latency);
  end
  // process average latencies
  if (!t_latency_req_1stdata.exists("total"))  begin
    t_latency_req_1stdata["total"]= m_t_latency;
    t_latency_req_1stdata["average"]= m_t_latency;
    if(!stop_process_steady_lat) begin
       t_latency_req_1stdata["steady"]= m_t_latency;
       t_latency_req_1stdata["total_steady"]= m_t_latency;
    end
  end else begin
    t_latency_req_1stdata["total"]  = t_latency_req_1stdata["total"] + m_t_latency;
    t_latency_req_1stdata["average"]= t_latency_req_1stdata["total"] / latency_nbr_received;
    if(!stop_process_steady_lat) begin 
       t_latency_req_1stdata["total_steady"]= t_latency_req_1stdata["totals_steady"] + m_t_latency;
       t_latency_req_1stdata["steady"] = t_latency_req_1stdata["total_steady"] / latency_steady_nbr_received;
    end
    //$display ("CLUDEBUG_SCB3 AVERAGE: t=%0t",t_latency_req_1stdata["average"]);
  end
end: min_max_average_latency 
// add table of latency by step of <cfg_t_step> ns
  begin:table_latency
    // example:
    // t_latency["0ns<t<25ns"] = nbr of case <25ns
    // t_latency["25ns<t<50ns"] = nbr of case between 25ns & 50ns
    int nbr_step = m_t_latency/m_t_step;
    string string_step;
    // case t_latency > 1000ns
    if (nbr_step>=m_t_max/m_t_step) begin
        string_step = $sformatf("t>%0t",m_t_max);
    end else begin
       string_step = $sformatf("%0t<t<%0t",nbr_step*m_t_step,(nbr_step+1)*m_t_step); //ex: 0ns<t<25ns
    end

    if (!nbr_latency_bystepns.exists(string_step)) begin
      nbr_latency_bystepns[string_step]=1;
    end else begin
      nbr_latency_bystepns[string_step]++;
    end
  end:table_latency

 endfunction:add_latency_graph_bystepns

function void newperf_test_latency_tools::add_latency (
                                        const ref s_txn_cycle m_latency
                                        ,int m_c_step
                                        ,int m_c_max  = cfg_c_max 
  );
 begin:min_max_average_latency_per_qos
  all_latency_nbr_received[m_latency.qos]++;
  if(!stop_process_steady_lat) all_latency_steady_nbr_received[m_latency.qos]++;
  // process min latency
  if (!latency_req_qos_1stdata.exists(m_latency.qos)) begin
    latency_req_qos_1stdata[m_latency.qos]["min"] = m_latency.cycles;
    latency_req_qos_1stdata[m_latency.qos]["max"] = m_latency.cycles;
    latency_req_qos_1stdata[m_latency.qos]["total"] = m_latency.cycles;
    latency_req_qos_1stdata[m_latency.qos]["average"] = m_latency.cycles;
    if(!stop_process_steady_lat) begin 
      latency_req_qos_1stdata[m_latency.qos]["total_steady"] = m_latency.cycles;
      latency_req_qos_1stdata[m_latency.qos]["steady"] = m_latency.cycles;
    end
  end else begin
    if (m_latency.cycles < latency_req_qos_1stdata[m_latency.qos]["min"])  latency_req_qos_1stdata[m_latency.qos]["min"] = m_latency.cycles;
    if (m_latency.cycles > latency_req_qos_1stdata[m_latency.qos]["max"])  latency_req_qos_1stdata[m_latency.qos]["max"] = m_latency.cycles;
    latency_req_qos_1stdata[m_latency.qos]["total"]  = latency_req_qos_1stdata[m_latency.qos]["total"] + m_latency.cycles;
    latency_req_qos_1stdata[m_latency.qos]["average"]= latency_req_qos_1stdata[m_latency.qos]["total"] / all_latency_nbr_received[m_latency.qos];
    if(!stop_process_steady_lat)begin 
       latency_req_qos_1stdata[m_latency.qos]["total_steady"]  = latency_req_qos_1stdata[m_latency.qos]["total_steady"] + m_latency.cycles;
       latency_req_qos_1stdata[m_latency.qos]["steady"]= latency_req_qos_1stdata[m_latency.qos]["total_steady"] / all_latency_steady_nbr_received[m_latency.qos];
    end
  end
end: min_max_average_latency_per_qos

if(!stop_process_steady_lat) q_latency_steady_tx.push_back(m_latency);

if (!stop_process_steady_lat) begin: _table_qos_latency
  // example:
  // m_latency["0<t<50 cycles"] = nbr of case <50 cycles
  // m_latency["50<t<100"] = nbr of case between 50 cycles & 100 cycles
  int idx_step = m_latency.cycles/m_c_step;
  string string_step;
  // case t_latency > 5000 cycles
    if (idx_step>=m_c_max/m_c_step) begin
      string_step = $sformatf("c>%0d",m_c_max);
     end else begin
       string_step = $sformatf("%0d<c<%0d",idx_step*m_c_step,(idx_step+1)*m_c_step); //ex: 0<t<50 cycles
     end

  if (nbr_latency_bystepcycle.exists(m_latency.qos)) begin: _qos
     if (!nbr_latency_bystepcycle[m_latency.qos].exists(string_step)) begin:_step1
        nbr_latency_bystepcycle[m_latency.qos][string_step]=1;
     end:_step1 else begin
       nbr_latency_bystepcycle[m_latency.qos][string_step]++;
     end
   end: _qos else begin: _e_qos
        nbr_latency_bystepcycle[m_latency.qos][string_step]=1;
  end: _e_qos
end: _table_qos_latency
 endfunction:add_latency

function void newperf_test_latency_tools::add_latency_graph_bystep  ( 
                                                                        const ref time m_t_latency  
                                                                       ,int m_step
);

// process average by step of cfg_step and max average by step to add a graph
case (tx_nbr) 
  0: begin
     t_latency_total_bystep[tx_step_nbr] =m_t_latency;
     tx_nbr++;
     end
  m_step-1 : begin
               t_latency_total_bystep[tx_step_nbr] = t_latency_total_bystep[tx_step_nbr] + m_t_latency;
               t_latency_average_bystep[tx_step_nbr] = t_latency_total_bystep[tx_step_nbr]/m_step;
               if (t_latency_average_bystep[tx_step_nbr] > t_latency_average_max_bystep)  t_latency_average_max_bystep = t_latency_average_bystep[tx_step_nbr];
               //$display("NEWCLUDEBUGb: step:%0d average:%0t, max:%0t, perc:%0d",tx_step_nbr,t_latency_average_bystep[tx_step_nbr], t_latency_average_max_bystep, int'(100*real'(t_latency_average_bystep[tx_step_nbr])/real'(t_latency_average_max_bystep)));
               tx_step_nbr++;
               tx_nbr =0;
               t_latency_total_bystep.delete(); // free space
               end
  default: begin
    t_latency_total_bystep[tx_step_nbr] = t_latency_total_bystep[tx_step_nbr] + m_t_latency;
    tx_nbr++;
    end 
endcase

// store the cfg_step last tranaction
q_t_latency_lasttx.push_back(m_t_latency);
if (q_t_latency_lasttx.size() > m_step) begin time discard = q_t_latency_lasttx.pop_front(); end// keep only last <cfg_step> number of transactions


endfunction:add_latency_graph_bystep

function void newperf_test_latency_tools::display_latency_graph_bystepns (
                                                                          string m_tab_name 
                                                                          ,time m_t_step
                                                                          ,time m_t_max
                                                                          ,int file
                                                                         );

    if (file == 0) begin
     $display("Error: Invalid file handle.");
        return;
    end
  $fwrite(file, "%0s\n", {200{"="}});
  $fwrite(file,`LABEL_NEWPERF);
  $fwrite(file,"%0s table",m_tab_name);
  
  if (nbr_latency_bystepns.size() ==0) begin
     $fwrite(file,"!!!!!! Warning no Graph because no data !!!!!!\n");
  end else begin
  // example:
  // t_latency["0ns<t<25ns"] = nbr of case <25ns
  // t_latency["25ns<t<50ns"] = nbr of case between 25ns & 50ns
  string string_step;
  string str_percentage_line= $sformatf("| percentage  by %0t step=",m_t_step); //All percentage on one line
  string str_nbr_of_case_line=`LABEL_NEWPERF;
  str_nbr_of_case_line= $sformatf("%0s %0s nbr_of_case by %0t step=",str_nbr_of_case_line, m_tab_name,m_t_step); //nbr of case on one line
  $fwrite(file,"%0s\n",{200{"="}});
  $fwrite(file,`LABEL_NEWPERF);
  $fwrite(file,"%0s table\n",m_tab_name);
  $fwrite(file,"%0s\n",{200{"-"}});
  $fwrite(file,"| %30s | %10s | %10s | graph\n","step", "nbr of case", "percentage");
  for (time t_i=0ns;t_i <m_t_max+m_t_step;t_i=t_i+m_t_step) begin:for_eachstep
      int nbr_of_case;
      int percentage;
      if (t_i>=m_t_max) begin
        string_step = $sformatf("t>%0t",m_t_max);
      end else begin
         string_step = $sformatf("%0t<t<%0t",t_i,t_i+m_t_step); //ex: 0ns<t<25ns
      end
      nbr_of_case = (nbr_latency_bystepns.exists(string_step))?nbr_latency_bystepns[string_step]:0;
      percentage  = (nbr_latency_bystepns.exists(string_step))?100*nbr_latency_bystepns[string_step]/latency_nbr_received:0; 
      str_percentage_line = $sformatf("%0s,%0d",str_percentage_line,percentage);
      str_nbr_of_case_line = $sformatf("%0s,%0d",str_nbr_of_case_line,nbr_of_case);
      if(!nbr_of_case) continue;  //stop here and go next step
      $fwrite (file,"| %30s | %10d | %10d%% |",string_step, nbr_of_case,percentage);
      for (int p=0;p<percentage;p++) begin
        $fwrite (file,"*");
      end
      $fwrite(file,"\n"); // newline
  end:for_eachstep
  $fwrite(file,"| %30s | %10d | %10s |","TOTAL\n", latency_nbr_received , "100\%");
  $fwrite(file,"%0s\n",str_percentage_line);
  $fwrite(file,"%0s\n",str_nbr_of_case_line);
  $fwrite(file,"%0s\n",{200{"-"}});
end // end nbr_latency_bystepns > 0 
endfunction:display_latency_graph_bystepns

function void newperf_test_latency_tools::display_latency_graph_bystep (
                                                                          string m_tab_name 
                                                                         ,int m_step
                                                                          ,int file
                                                                       );
  string str_average_line=`LABEL_NEWPERF;
  int max_step= t_latency_average_bystep.size();
  str_average_line= $sformatf("%0s %0s average by %0d transactions step=",str_average_line,m_tab_name,m_step); //average on one line
  if (file == 0) begin
     $display("Error: Invalid file handle.");
        return;
  end
  $fwrite(file,"%0s\n",{200{"="}});
  $fwrite(file,`LABEL_NEWPERF);
  $fwrite(file,"%0s latency table\n",m_tab_name);
  if (max_step==0) begin
    $fwrite(file,"!!!!!! Warning no Graph because no data !!!!!!\n");
 end else begin
  $fwrite(file,"| %30s | %10s | %10s | graph\n","step", "latency average", "N/A");
  for (int i=0;i <max_step;i++) begin:for_eachstep
    int percentage= int'(100*real'(t_latency_average_bystep[i])/real'(t_latency_average_max_bystep));
    str_average_line = $sformatf("%0s,%0.2f",str_average_line,real'(t_latency_average_bystep[i])/1000);
    $fwrite(file,"| %30s | %10t | %10d |", $sformatf("%0d<transactions<%0d",i*m_step,m_step*(i+1)),t_latency_average_bystep[i],"");
    for (int p=0;p<percentage;p++) begin
      $fwrite(file,"*");
    end
     $fwrite(file,"\n"); // newline
  end:for_eachstep
  $fwrite(file,"%0s\n",str_average_line);
end // end max_step >0
  $fwrite(file,"%0s\n",{200{"-"}});
endfunction: display_latency_graph_bystep

function void newperf_test_latency_tools::display_latency_graph_lasttx (
                                                                        string m_tab_name 
                                                                        ,int m_step
                                                                        ,int file
);
  time t_max=0ns;
  string str_lasttx_line=`LABEL_NEWPERF;
  str_lasttx_line= $sformatf("%0s %0s latency of the %0d last transactions=",str_lasttx_line, m_tab_name,m_step); //lasttx on one line
  if (file == 0) begin
     $display("Error: Invalid file handle.");
        return;
  end
  
  $fwrite(file,"%0s\n",{200{"="}});
  $fwrite(file,`LABEL_NEWPERF);
  $fwrite(file,"%0s last latency table\n",m_tab_name);
  if (q_t_latency_lasttx.size()==0) begin
    $fwrite(file,"!!!!!! Warning no Graph because no data !!!!!!");
  end else begin
  $fwrite(file,"| %30s | %10s | %10s | graph\n","step", "latency lasttx", "N/A");
  foreach (q_t_latency_lasttx[i]) begin:extract_max
    if (q_t_latency_lasttx[i]>t_max) t_max = q_t_latency_lasttx[i];
  end:extract_max

  foreach (q_t_latency_lasttx[i]) begin:for_eachtx
     int percentage= int'(100*real'(q_t_latency_lasttx[i])/real'(t_max));
     str_lasttx_line = $sformatf("%0s,%0.2f",str_lasttx_line,real'(q_t_latency_lasttx[i])/1000);
     $fwrite(file,"| %30s | %10t | %10d |", $sformatf("tx idx=%0d",latency_nbr_received-m_step+i),q_t_latency_lasttx[i],"");
     for (int p=0;p<percentage;p++) begin
       $fwrite(file,"*");
     end
     $fwrite(file,"\n"); // newline
  end:for_eachtx
  $fwrite(file,"%0s\n",str_lasttx_line);
  end // end max_step >0
  $fwrite(file,"%0s\n",{200{"-"}});
endfunction: display_latency_graph_lasttx

function void newperf_test_latency_tools::fdisplay_latency (
  string m_tab_name 
  ,int m_c_step
  ,int m_c_max
);
int file;

if (q_latency_steady_tx.size>0) begin: _print_in_file // create a file if there are datas
   file = $fopen($sformatf("./latencies_%0s%0d_%0s.csv",cfg_e_type.name(),cfg_aiu_id,m_tab_name),"w");
// print AVERAGE,MIN,MAX for each QOS
foreach(latency_req_qos_1stdata[i]) begin: _foreach_qos
   $fdisplay(file,$sformatf("!!! the stats on ALL txn with qos=%0d!!!",i));
   $fdisplay(file,"min,steady,max,average");
   $fdisplay(file,$sformatf("%0d,%0d,%0d,%0d\n",latency_req_qos_1stdata[i]["min"],latency_req_qos_1stdata[i]["steady"],latency_req_qos_1stdata[i]["max"],latency_req_qos_1stdata[i]["average"]));
end: _foreach_qos

 

// Print one line the nbr de case by step of < m_c_cfg
  foreach(nbr_latency_bystepcycle[qos]) begin: _foreach_qos
   string str_nbr_of_case_line;
   string string_step;
   $fdisplay(file,$sformatf("!!! the graphs by step of %0d cycles with qos:%0d!!!",m_c_step,qos));
   for (int c_i=0;c_i <m_c_max+m_c_step;c_i=c_i+m_c_step) begin:_foreach_cycle
    int nbr_of_case;
    if (c_i>=m_c_max) begin
      string_step = $sformatf("c>%0d",m_c_max);
    end else begin
       string_step = $sformatf("%0d<c<%0d",c_i,c_i+m_c_step); 
    end
    nbr_of_case = (nbr_latency_bystepcycle[qos].exists(string_step))?nbr_latency_bystepcycle[qos][string_step]:0;
    str_nbr_of_case_line = $sformatf("%0s,%0d",str_nbr_of_case_line,nbr_of_case);
  end: _foreach_cycle
  $fdisplay(file,"%0s",str_nbr_of_case_line);
end: _foreach_qos
  $fdisplay(file,"");

// COLUMN TITLE
  $fdisplay(file,"!!! only latency when all SELECTED agents are still sending txn !!!");
  $fwrite(file,"idx,");
foreach(latency_req_qos_1stdata[i]) begin: _foreach_qos_title
  $fwrite(file,$sformatf("%0s%0d_qos%0d,",cfg_e_type.name(),cfg_aiu_id,i));
end: _foreach_qos_title
  $fwrite(file,"\n"); 
// Print each column [ line nbr , latency for qos<i> , latency for qos<i+1> ...]
begin : _print_col
  int line_of_table;
  int idx[$];
do 
   begin: _do_print
   line_of_table++;
   $fwrite(file,$sformatf("%0d,",line_of_table));
   foreach(latency_req_qos_1stdata[i]) begin: _foreach_qos_col
      idx = q_latency_steady_tx.find_first_index with (item.qos == i );
      if (idx.size()>0) begin: _if_idx
          $fwrite(file,$sformatf("%0d,",q_latency_steady_tx[idx[0]].cycles));
          q_latency_steady_tx.delete(idx[0]);
      end: _if_idx
      else begin: _no_if_idx
          $fwrite(file,","); // print empty value
      end: _no_if_idx
    end: _foreach_qos_col
   $fwrite(file,"\n"); 
  end: _do_print
while (q_latency_steady_tx.size()>0);
end:_print_col

$fclose(file);
end: _print_in_file

endfunction: fdisplay_latency
