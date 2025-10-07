////////////////////////////////////////////////////////////////////////////////
//
// Author       : 
// Purpose      : Customer testbench Performance Metrics
// Description  :    
//
////////////////////////////////////////////////////////////////////////////////
<%
const chipletObj = obj.lib.getAllChipletRefs();
const chipletInstances = obj.lib.getAllChipletInstanceNames();
%>

class ncore_perf_metrics extends uvm_component;

    `uvm_component_utils(ncore_perf_metrics)

    // Parameters
    string native_interface;
    string component_type;
    bit isSlave;
    int data_width;
    real clock_period;
    real frequency;
    typedef bit [<%=chipletObj[0].AiuInfo[0].wAddr%> -1 : 0] addr_t;
    typedef bit [2:0] size_t;
    typedef bit [7:0] len_t;

    // Transaction Counter
    int num_txn_initiated;
    int num_txn_completed;
    int txn_num;

    // Latency Parameters
    real latency_q[$];
    int  latency_in_clock_cycle_q[$];
    real min_latency;
    real max_latency;
    real avg_latency;

    // Bandwidth Parameters
    real bandwidth_q[$];
    real bandwidth_2_q[$];
    real min_bandwidth;
    real max_bandwidth;
    real avg_bandwidth;

    // Bandwidth Utilization Ratio
    real theoretical_bandwidth;
    real bandwidth_utilization_q[$];

    // Transaction data
    addr_t     addr_q[$];
    string     region_q[$];
    int        mem_region_q[$];
    string     txn_type_q[$];

    // Extern Function/Task
    extern function new(string name = "ncore_perf_metrics", uvm_component parent = null);
    extern function void build_phase  ( uvm_phase phase );
    extern function void extract_phase( uvm_phase phase );
    extern function void check_phase  ( uvm_phase phase );
    extern function void report_phase ( uvm_phase phase );
    extern function void final_phase  ( uvm_phase phase );
    extern function void calculate_latency_bandwidth(real start_time, real end_time, size_t size, len_t len);
    extern function void store_txn_data(addr_t addr, string txn_type);
    extern function string check_memregion_id(addr_t addr);


endclass : ncore_perf_metrics

//******************************************************************************
// Function : new
// Purpose  : 
//******************************************************************************
function ncore_perf_metrics::new(string name = "ncore_perf_metrics", uvm_component parent = null);
    super.new(name,parent);
endfunction : new

//******************************************************************************
// Function : build_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_metrics::build_phase(uvm_phase phase);
    super.build_phase(phase);
    frequency = (1/clock_period) * (10**6) ; //in MHz
    theoretical_bandwidth = (frequency*data_width)/8;  // MB/s
endfunction: build_phase

//******************************************************************************
// Function : calculate_latency_bandwidth
// Purpose  : 
//******************************************************************************
function void ncore_perf_metrics::calculate_latency_bandwidth(real start_time, real end_time, size_t size,len_t len);
    real latency =  end_time - start_time; // ps

    //FIXME : Start
    //-------------------------------------------------------
    //  Theoretical Bandwidth(BW_theo) = Clock Frequency × DataBus Width
    //
    //  Effective_Bandwidth = Total_Data_Bytes / Latency
    //  
    //  Bandwidth_Utilization_Ratio = (Effective_Bandwidth / Theoretical_Bandwidth)× 100%
    // 
    //------------------------------------------------------
    real bandwidth = (64 / (latency*1.0)) * 1000000000.0;
    real bandwidth_2 = ((len * (2**size)) / latency) * 1000000000000.0;  // B/s
    int  latency_clock = (latency /clock_period );
    real bandwidth_utilization = ((bandwidth_2/1000000.0)/ theoretical_bandwidth)*100;
    //FIXME : End

    latency_q.push_back(latency);
    latency_in_clock_cycle_q.push_back(latency_clock);
    bandwidth_q.push_back(bandwidth);
    bandwidth_2_q.push_back((bandwidth_2/1000000.0)); // MB/s
    bandwidth_utilization_q.push_back(bandwidth_utilization);

    `uvm_info(get_name(), $sformatf("Received latency: %.2f, bandwidth: %.2f, Latency in Clock cycle : %.2f  ", latency, bandwidth_2, latency_clock), UVM_DEBUG);
    txn_num++;
endfunction : calculate_latency_bandwidth

//******************************************************************************
// Function : calculate_latency_bandwidth
// Purpose  : 
//******************************************************************************
function void ncore_perf_metrics::store_txn_data(addr_t addr, string txn_type);
    string memregion;
    addr_q.push_back(addr);
    memregion = check_memregion_id(addr);
    region_q.push_back(memregion);
    txn_type_q.push_back(txn_type);
endfunction : store_txn_data

//******************************************************************************
// Function : check_memregion_id
// Purpose  : 
//******************************************************************************
function string ncore_perf_metrics::check_memregion_id(addr_t addr);

    int temp, region_num;
    // temp = ncoreConfigInfo::map_addr2dmi_or_dii(addr,region_num);
    // //mem_region_q.push_back(region_num);

    // foreach(ncoreConfigInfo::memregions_info[region]) begin
    //     if (ncoreConfigInfo::is_dii_addr(addr)) begin
    //         return (isSlave ? $sformatf("%0d",region_num) : $sformatf("DII -> %0d",region_num));
    //     end
    //     if (ncoreConfigInfo::is_dmi_addr(addr)) begin 
    //         if(!ncoreConfigInfo::get_addr_gprar_nc(addr))begin
    //             return (isSlave ? $sformatf("%0d",region_num) : $sformatf("DMI (NC=0) -> %0d",region_num));
    //         end
    //         if(ncoreConfigInfo::get_addr_gprar_nc(addr))begin
    //             return (isSlave ? $sformatf("%0d",region_num) : $sformatf("DMI (NC=1) -> %0d",region_num));
    //         end
    //     end
    // end
    return "UNKNOWN";
endfunction: check_memregion_id

//******************************************************************************
// Function : extract_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_metrics::extract_phase( uvm_phase phase );
    super.extract_phase(phase); 

    // Find The Min/Max/Avg Latency
    foreach(latency_q[i]) begin
        if(latency_q[i] > max_latency) begin
            max_latency = latency_q[i];
        end
        if(i == 0) begin
            min_latency = latency_q[i];
        end
        if (latency_q[i] < min_latency) begin
            min_latency = latency_q[i];
        end
        avg_latency = avg_latency + latency_q[i];
    end
    avg_latency = (latency_q.size() > 0) ? avg_latency/latency_q.size() : 0;

    // Find The Min/Max/Avg Bandwidth
    foreach(bandwidth_q[i]) begin
        if(bandwidth_q[i] > max_bandwidth) begin
            max_bandwidth = bandwidth_q[i];
        end
        if(i == 0) begin
            min_bandwidth = bandwidth_q[i];
        end
        if (bandwidth_q[i] < min_bandwidth) begin
            min_bandwidth = bandwidth_q[i];
        end
        avg_bandwidth = avg_bandwidth + bandwidth_q[i];
    end
    avg_bandwidth = (bandwidth_q.size() > 0) ? avg_bandwidth/bandwidth_q.size() : 0;

endfunction : extract_phase

//******************************************************************************
// Function : check_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_metrics::check_phase( uvm_phase phase );
    super.check_phase(phase);
    `uvm_info(get_name(), $sformatf("Check Phase "), UVM_DEBUG);
endfunction : check_phase

//******************************************************************************
// Function : report_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_metrics::report_phase( uvm_phase phase );

    string table_line = {"+----------",                // Txn no
                         "+------------------------",  // Latency
                         "+------------------------",  // Bandwidth
                         "+------------------------",  // Target -> Region
                         "+------------------------",  // Transaction Type
                         "+------------------------",  // New Bandwidth
                         "+------------------------+"};// Bandwidth Utilization
    int count = 0;
    string unique_target [$];
    string unique_txn[$];

    // Latency Parameters
    real min_latency;
    real max_latency;
    real avg_latency;

    // Bandwidth Parameters
    real min_bandwidth;
    real max_bandwidth;
    real avg_bandwidth;

    // Bandwidth Parameters
    real min_bandwidth_2;
    real max_bandwidth_2;
    real avg_bandwidth_2;

    // Bandwidth Utilization
    real min_bandwidth_utilization;
    real max_bandwidth_utilization;
    real avg_bandwidth_utilization;

    super.report_phase(phase); 
    `uvm_info(get_name(),$sformatf("Performance Metrics : %s",get_name()), UVM_LOW);

    unique_target = region_q.unique();
    unique_txn = txn_type_q.unique();

    foreach(unique_target[target]) begin : Target
        foreach(unique_txn[txn]) begin : Transaction
            foreach(latency_q[i])begin : All_TXN
                if((region_q[i] == unique_target[target]) && (txn_type_q[i] == unique_txn[txn])) begin
                    if(count == 0) begin
                        // Title
                        if(isSlave)begin
                            $display("Performance Metrics [Slave] : %s [%s]",(get_name().substr(0, (get_name().len()-14))), component_type);
                        end
                        else begin
                            $display("Initiator : %s",get_name());
                            $display("Target    : %s",unique_target[target]);
                        end
                        $display("Frequency : %.2f MHz  |  Clock : %.2f ps", frequency,clock_period);
                        $display("Theoretical Bandwidth : %.2f MB/s", theoretical_bandwidth);

                        // Header
                        $display("%s", table_line);
                        $display("| %-8s ",   "Txn no",
                                 "| %-22s ",  "Latency(ps) (in clock)",
                                 "| %-22s ",  "Bandwidth",
                                 "| %-22s ",  (isSlave ? "Region" : (region_q[i].substr(0, 2) == "DII") ? "Target -> Region" : "Target (NC) -> Region"),
                                 "| %-22s ",  "Transaction Type",
                                 "| %-22s ",  "New Bandwidth(MB/s)",
                                 "| %-22s |", "Bandwidth Utilization");
                        $display("%s", table_line);
                    end
                    // Table Data
                    $display("| %-8d ",   (count+1),
                             "| %-22s ",  $sformatf("%.2f (%0d)",latency_q[i], latency_in_clock_cycle_q[i]),
                             "| %-22s ",  $sformatf("%.2f",bandwidth_q[i]),
                             "| %-22s ",  region_q[i],
                             "| %-22s ",  $sformatf("%s",txn_type_q[i]),
                             "| %-22s ",  $sformatf("%.2f",bandwidth_2_q[i]),
                             "| %-22s |", $sformatf("%.2f",bandwidth_utilization_q[i]));
                    count++;

                    // Find The Min/Max/Avg Latency
                    max_latency = (latency_q[i] > max_latency) ? latency_q[i] : max_latency;
                    min_latency = ((count == 1) || (latency_q[i] < min_latency)) ? latency_q[i] : min_latency;
                    avg_latency = avg_latency + latency_q[i];

                    // Find The Min/Max/Avg Bandwidth
                    max_bandwidth = (bandwidth_q[i] > max_bandwidth) ? bandwidth_q[i] : max_bandwidth;
                    min_bandwidth = ((count == 1) || (bandwidth_q[i] < min_bandwidth)) ? bandwidth_q[i] : min_bandwidth;
                    avg_bandwidth = avg_bandwidth + bandwidth_q[i];

                    // Find The Min/Max/Avg Bandwidth 2
                    max_bandwidth_2 = (bandwidth_2_q[i] > max_bandwidth_2) ? bandwidth_2_q[i] : max_bandwidth_2;
                    min_bandwidth_2 = ((count == 1) || (bandwidth_2_q[i] < min_bandwidth_2)) ? bandwidth_2_q[i] : min_bandwidth_2;
                    avg_bandwidth_2 = avg_bandwidth_2 + bandwidth_2_q[i];

                    // Find The Min/Max/Avg Bandwidth Utilization
                    max_bandwidth_utilization = (bandwidth_utilization_q[i] > max_bandwidth_utilization) ? bandwidth_utilization_q[i] : max_bandwidth_utilization;
                    min_bandwidth_utilization = ((count == 1) || (bandwidth_utilization_q[i] < min_bandwidth_utilization)) ? bandwidth_utilization_q[i] : min_bandwidth_utilization;
                    avg_bandwidth_utilization = avg_bandwidth_utilization + bandwidth_utilization_q[i];

                end // if
            end : All_TXN
            if(count > 0) begin
                avg_latency   = avg_latency/count;
                avg_bandwidth = avg_bandwidth/count;
                avg_bandwidth_2 = avg_bandwidth_2/count;
                avg_bandwidth_utilization = avg_bandwidth_utilization/count;

                $display("%s", table_line);

                $display("| %-8s ",   "Max",
                         "| %-22s ",  $sformatf("%.2f (%0d)",max_latency,(max_latency/clock_period)),
                         "| %-22s ",  $sformatf("%.2f",max_bandwidth),
                         "| %-22s ",  "-",
                         "| %-22s ",  "-",
                         "| %-22s ",  $sformatf("%.2f",max_bandwidth_2),
                         "| %-22s |", $sformatf("%.2f",max_bandwidth_utilization));

                $display("| %-8s ",   "Min",
                         "| %-22s ",  $sformatf("%.2f (%0d)",min_latency,(min_latency/clock_period)),
                         "| %-22s ",  $sformatf("%.2f",min_bandwidth),
                         "| %-22s ",  "-",
                         "| %-22s ",  "-",
                         "| %-22s ",  $sformatf("%.2f",min_bandwidth_2),
                         "| %-22s |", $sformatf("%.2f",min_bandwidth_utilization));

                $display("| %-8s ",   "Avg",
                         "| %-22s ",  $sformatf("%.2f (%0d)",avg_latency,(avg_latency/clock_period)),
                         "| %-22s ",  $sformatf("%.2f",avg_bandwidth),
                         "| %-22s ",  "-",
                         "| %-22s ",  "-",
                         "| %-22s ",  $sformatf("%.2f",avg_bandwidth_2),
                         "| %-22s |", $sformatf("%.2f",avg_bandwidth_utilization));

                $display("%s", table_line);

	            `uvm_info($sformatf("%s : summary", get_name()), $sformatf("==============================================================="), UVM_NONE);
	            `uvm_info($sformatf("%s : summary", get_name()), $sformatf("Performance Results"), UVM_NONE);
	            `uvm_info($sformatf("%s : summary", get_name()), $sformatf("==============================================================="), UVM_NONE);
                if(isSlave) begin
	                `uvm_info($sformatf("%s : summary", get_name()), $sformatf(" Interface : %s, REGION: %0s, TXN_TYPE: %s, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f KB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",native_interface, unique_target[target],unique_txn[txn], count, avg_bandwidth_2, avg_latency, min_latency, max_latency), UVM_NONE);
                end else begin
	                `uvm_info($sformatf("%s : summary", get_name()), $sformatf("SOURCE: %s (%s), REGION: %0s, TXN_TYPE: %s, TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f KB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps",get_name(),native_interface, unique_target[target],unique_txn[txn], count, avg_bandwidth_2, avg_latency, min_latency, max_latency), UVM_NONE);
                end
$display();

            end
            count = 0;
            min_latency = 0 ;
            max_latency = 0 ;
            avg_latency = 0 ;
            min_bandwidth = 0 ;
            max_bandwidth = 0 ;
            avg_bandwidth = 0 ;
            min_bandwidth_2 = 0 ;
            max_bandwidth_2 = 0 ;
            avg_bandwidth_2 = 0 ;
            min_bandwidth_utilization = 0 ;
            max_bandwidth_utilization = 0 ;
            avg_bandwidth_utilization = 0 ;

        end : Transaction
    end : Target


/*
    `uvm_info("Performance", $sformatf("==============================================================="), UVM_NONE);
	`uvm_info("Performance", $sformatf("Performance Results of %s",get_name()), UVM_NONE);
	`uvm_info("summary", $sformatf(" TOTAL_NUM_OF_TXNS: %0d, Bandwidth(avg): %.2f KB/s, Latency(avg/min/max): %.2f ps/ %.2f ps/ %.2f ps", txn_num, avg_bandwidth, avg_latency, min_latency, max_latency), UVM_NONE);
	`uvm_info("Performance", $sformatf("==============================================================="), UVM_NONE);

    $display();
*/
endfunction : report_phase

//******************************************************************************
// Function : final_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_metrics::final_phase( uvm_phase phase );
    super.final_phase(phase);
endfunction : final_phase
