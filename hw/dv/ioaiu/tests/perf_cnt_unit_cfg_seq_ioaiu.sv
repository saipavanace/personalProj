<%
var numChiAiu       = 0;
var numIoAiu        = 0;
var found_csr_access_ioaiu =0;
var csrAccess_chi_idx = 0;
var csrAccess_io_idx = 0;
var cs
var found_csr_access_chi =0;
var qidx = 0;

for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if( obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-C" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-D" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")
    {
        if ((found_csr_access_chi==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_chi_idx = numChiAiu;
            found_csr_access_chi = 1;
            }
        numChiAiu = numChiAiu + 1;
    } else {
        if ((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_io_idx = numIoAiu;
            found_csr_access_ioaiu = 1;
            }
        numIoAiu = numIoAiu + 1;
    }
}
var regPrefixName = function() {
                                if (obj.BlockId.charAt(0)=="d")
                                    {return obj.BlockId.match(/[a-z]+/i)[0].toUpperCase();} //dmi,dii,dce,dve => DMI,DII,DVE 
                                if ((obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-A')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-B')) 
                                    {return "CAIU";}
                                return "XAIU"; // by default
                                };
%>

<%function generateRegPath() {
    if ((obj.testBench == 'io_aiu')){
        if(obj[obj.AgentInfoName][obj.Id].nNativeInterfacePorts > 1) {
            return obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix+'_'+obj.multiPortCoreId;
        } else {
            return obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix;
        }
    } else {
        return obj[obj.AgentInfoName][obj.Id].strRtlNamePrefix;

    }
}%>

class perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>  extends uvm_reg_sequence;
    `uvm_object_utils(perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>)
    

    uvm_status_e        status;

    ral_sys_ncore       m_regs;

    <%=obj.BlockId%>_perf_cnt_units      perf_counters;
    
    int                 counters_id[];
    bit                 en_counter_random_way;

    const int           nPerfCounters = <%=obj.DutInfo.nPerfCounters%>;
    int                 pct_counters_enable = nPerfCounters/2;

    int                 iteration;
    string              blockreg_str = "<%=generateRegPath()%>";

    string fields_cntcr_reg [] =
    {
        "CntEvtFirst",
        "CntEvtSecond",
        "MinStallPeriod",
        "FilterSel",
        "SSRCount",
        "CounterCtl",
        "InterruptEn",
        "CountClr",
        "CountEn",   
        "OverFlowStatus"
    };

    string fields_cntvr_reg [] =
    {
        "CountVal"
    };
    string fields_cntsr_reg [] =
    {
        "CountSatVal"
    };
    //Pmon 3.4 feature
    <% if (obj.BlockId.includes("dii") || obj.BlockId.includes("dmi") || (obj.testBench =="io_aiu") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>

    //// BW Counter Filter Register
    string fields_bcntfr_reg [] =
    {
        "FilterVal",
        "FilterSel",
        "FilterEn"

    };
    string fields_bcntmr_reg [] =
    {
        "MaskVal"

    };
    ////////////////////////////////////
    /////////// Latency counter ////////////

    string fields_lcntcr_reg[] =
    {
        "LatencyPreScale",
        "RdWrLatency",
        "LatencyBinOffset",
        "LatencyCountEn"

    };
    /////////////////////////////////
    <% } %>  
    //Pmon 3.4 feature
    string fields_mcntr_reg [] =
    {
        "LocalCountEnable",
        "LocalCountClear",
        "MasterCountEnable"

    };


    extern task write_csr(uvm_reg_field field, uvm_reg_data_t wr_data);
    extern task read_csr(uvm_reg_field field, output uvm_reg_data_t fieldVal);
    extern function uvm_reg_data_t mask_data(int lsb, int msb);

    <% if ((obj.testBench == "fsys") || (obj.testBench == "emu")){ %>
    bit en_rw_csr_from_ioaiu=1'b1; // by default set CSR with IO => update in body
    <% if ( numChiAiu > 0){ %>
        //chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=csrAccess_chi_idx%>)   m_chi_csr_vseq;
    <% } %>
    <% if ( numIoAiu > 0){ %>
    ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=csrAccess_io_idx%>;
    extern task write_csr<%=csrAccess_io_idx%>(input ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data);
    extern task read_csr<%=csrAccess_io_idx%>(input ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0]); 
    <% } %>
    <% } %>
    //
    // Constructor
    //
    function new(string name="perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>");
        super.new(name);
    endfunction

    //
    // Body
    //
    task body();
        <% if ((obj.testBench == "fsys") || (obj.testBench == "emu")){ %> 
      <% if ( numChiAiu > 0){ %>
        //en_rw_csr_from_ioaiu=1'b0; 
        //if(!(uvm_config_db#(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=csrAccess_chi_idx%>))::get(.cntxt( null ),.inst_name( "" ),.field_name( "chiaiu<%=csrAccess_chi_idx%>_vseq" ),.value( m_chi_csr_vseq) )))
         //       `uvm_error(get_name(), "Cannot get m_chi_csr_vseq")
      <% } %>
      <% if ( numIoAiu > 0){ %>
         if(!(uvm_config_db#(ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=csrAccess_io_idx%>[0]" ),.value( m_ioaiu_vseqr<%=csrAccess_io_idx%> ) )))
                `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=csrAccess_io_idx%>")
      <% } %>
        <% } %> 
        `uvm_info("run_main", "New cfgs for perf counter randomized for <%=obj.BlockId%>", UVM_NONE)

        //#Stimulus.DII.Pmon.v3.2.Random
        if(! perf_counters.randomize())  `uvm_fatal("Body_seq", "Error randomization perf_counters for <%=obj.BlockId%>")
        //Pmon 3.4 feature
        
        // When new cfg generated, Clear all counters, need count_enable to 1
        `uvm_info("run_main", "Force clear internal perf counters for <%=obj.BlockId%>", UVM_NONE)
        if (perf_counters.perfmon_local_count_clear) begin
            `uvm_info("run_main", "local count clear trigged perf counters for <%=obj.BlockId%>", UVM_NONE)
            //#Stimulus.DII.Pmon.v3.4.LocalClear
            //#Stimulus.CHIAIU.Pmon.v3.4.LocalClear
            //#Stimulus.IOAIU.Pmon.v3.4.LocalClear
            //#Stimulus.DVE.PerfMon.PerfCountClear
            write_local_count_clear(1'b1);
        end
        else begin
            for(int i=0;i<nPerfCounters ;i++) begin
                write_count_clear(i); // Will clear CountVal,CountSatVal and Overflow Status registers
            end
        end

        for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
            perf_counters.m_cov_perf_cnt[i].sample();
            //Pmon 3.4 feature
            <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

            perf_counters.m_cov_bw_cnt[i].sample();
    
            <% }  %>  
        end
        //Pmon 3.4 feature
        <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

        perf_counters.m_cov_lct_cnt.sample();
        <% }  %>  
        perf_counters.m_cov_main_cnt.sample();

        `uvm_info("run_main", "Write all CNCTR registers for <%=obj.BlockId%>",UVM_NONE)
        write_all_cntcr();  
        //Pmon 3.4 feature
        <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu")|| obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
	if (perf_counters.pmon_bw_test) begin        
	    `uvm_info("run_main", "Write all BCNTFR registers for <%=obj.BlockId%>",UVM_NONE)
        //#Stimulus.DII.Pmon.v3.4.BwFilterFixed
        //#Stimulus.DII.Pmon.v3.4.BwFilterRand
        //#Stimulus.CHIAIU.Pmon.v3.4.BwFilterFixed
        //#Stimulus.CHIAIU.Pmon.v3.4.BwFilterRand
        //#Stimulus.IOAIU.Pmon.v3.4.BwFilterFixed
        //#Stimulus.IOAIU.Pmon.v3.4.BwFilterRand
            write_all_bw_registers(); 
            // ENABLE FILTER FOR BANDWIDTH COUNTER
            for(int i=0;i<nPerfCounters ;i++) begin
               
            	if( perf_counters.force_filter_enable[i] )
            	write_filter_enable(i,1'b1);
    
            end
	end
	if (perf_counters.pmon_latency_test) begin
          `uvm_info("run_main", "Write all LCNTCR registers for <%=obj.BlockId%>",UVM_NONE)
          //#Stimulus.DII.Pmon.v3.4.LatencyFixed 
          //#Stimulus.DII.Pmon.v3.4.LatencyRand 
          //#Stimulus.CHIAIU.Pmon.v3.4.LatencyFixed 
          //#Stimulus.CHIAIU.Pmon.v3.4.LatencyRand
          //#Stimulus.IOAIU.Pmon.v3.4.LatencyFixed 
          //#Stimulus.IOAIU.Pmon.v3.4.LatencyRand
          write_all_lct_fields(); 
          if( perf_counters.force_latency_count_enable)
          write_latency_enable(1'b1);
	end
        <% } %> 
        //Wait that cfg is going into registers
        #100ns
        for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
            perf_counters.m_cov_perf_cnt[i].sample();
            //Pmon 3.4 feature
            <% if (obj.BlockId.includes("dii") ||(obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

           perf_counters.m_cov_bw_cnt[i].sample();
   
           <% }  %>  
        end
        //Pmon 3.4 feature
        <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

        perf_counters.m_cov_lct_cnt.sample();
        <% }  %>  
        perf_counters.m_cov_main_cnt.sample();

    endtask
    task enable_all_counters();
    
    if($test$plusargs("overflow_test")) begin
            write_interrupt_enable(.id(iteration),.from_cfg_obj(1'b1));
    end else if(en_counter_random_way) begin
       // Will choose randomly which counter to be activated
       // Initialize counters_id array and shuffle counter order 
       // By default, only half of counters will be activated
           counters_id = new [nPerfCounters];
           foreach (counters_id[x]) counters_id[x] = x;
           counters_id.shuffle();
           //Activate/Deactivate half of perf counters randomly
           //#Stimulus.DII.Pmon.v3.2.EnableDisable   
           for(int i=0;i<pct_counters_enable ;i++) begin
               write_count_enable(counters_id[i],1'b1);
           end
           for(int i=pct_counters_enable;i<nPerfCounters ;i++) begin
               write_count_enable(counters_id[i],1'b0);
           end

       end else begin // Enable counters
            //Pmon 3.4 feature
            if (perf_counters.perfmon_local_count_enable) begin
                `uvm_info("run_main", "local count enable trigged perf counters for <%=obj.BlockId%>", UVM_NONE)
                //#Stimulus.DII.Pmon.v3.4.LocalEnableDisable 
                //#Stimulus.CHIAIU.Pmon.v3.4.LocalEnableDisable
                //#Stimulus.IOAIU.Pmon.v3.4.LocalEnableDisable
                //#Stimulus.DVE.PerfMon.LocalTrigger
                write_local_count_enable(1'b1);
            end
            else begin
                for(int i=0;i<nPerfCounters ;i++) begin
                
                    if( perf_counters.force_count_enable[i] )
                        write_count_enable(i,1'b1);
                
                end

            end
       end
       for(int i=0;i<<%=obj.DutInfo.nPerfCounters%> ;i++) begin
           perf_counters.m_cov_perf_cnt[i].sample();
           //Pmon 3.4 feature
           <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
           perf_counters.m_cov_bw_cnt[i].sample();
           <% }  %>  
       end
       //Pmon 3.4 feature
       <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>

       perf_counters.m_cov_lct_cnt.sample();
       <% }  %>  
       perf_counters.m_cov_main_cnt.sample();

       <%if (obj.BlockId.includes("dve")) {%>
          if( perf_counters.force_master_count_enable)
            write_master_count_enable(1'b1, 1'b0);
       <%}%>

    endtask: enable_all_counters
    /////////////////////////////////////////////////////////////
    //                      Write tasks for 
    //              Counter control Register (xCNTCR)
    /////////////////////////////////////////////////////////////

    task write_cnt_value_reg(int id, int data);
        uvm_reg_data_t fieldVal = uvm_reg_data_t'(data);
        string field = fields_cntvr_reg[0]; // "Count Value"
       
        write_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>CNTVR%0d",id)).get_field_by_name(field), fieldVal);
   
        `uvm_info(get_name(), $sformatf("Writing %s field register with value %h", field, fieldVal), UVM_NONE)
    endtask: write_cnt_value_reg

    task write_cnt_saturation_reg(int id, int data);
        uvm_reg_data_t fieldVal = uvm_reg_data_t'(data);
        string field = fields_cntsr_reg[0]; // "Count Saturation Value"
       
        write_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>CNTSR%0d",id)).get_field_by_name(field), fieldVal);
        
        
        `uvm_info(get_name(), $sformatf("Writing %s field register with value %h", field, fieldVal), UVM_NONE)
       
    endtask: write_cnt_saturation_reg

    task write_all_cnt_value_reg(int data);
        for ( int i=0; i< nPerfCounters ; i++) begin
            write_cnt_value_reg(i,data);
        end 
    endtask: write_all_cnt_value_reg

    task write_all_cnt_saturation_reg(int data);     
        for(int i=0; i< nPerfCounters  ; i++) begin
            write_cnt_saturation_reg(i,data);
        end
    endtask: write_all_cnt_saturation_reg


    task write_all_cntcr();
        foreach (perf_counters.cfg_reg[i]) begin
            `uvm_info(get_name(),$sformatf("Writing all fields of CNTCR%0d register for <%=obj.BlockId%>",i), UVM_LOW) 
            write_all_cntcr_fields(i);
        end
    endtask: write_all_cntcr

    task write_all_cntcr_fields(int id);
        for(int i=0; i < fields_cntcr_reg.size()-3; i++) begin
             // -3 to  avoid counter_clear / counter_enable / overflow_status register
            write_field_cntcr(id, fields_cntcr_reg[i], 1'b1);
        end
        // write_count_enable(id, 1'b1, 1'b0); // Will be written separate
    endtask: write_all_cntcr_fields


    task write_field_cntcr(int id, string field_name, bit from_cfg_obj=1'b1, uvm_reg_data_t wr_data=0);
        if(from_cfg_obj)begin
            get_write_data_cntcr(id, field_name, wr_data);
        end
 
       `uvm_info(get_name(),
        $sformatf("For <%=obj.BlockId%> Writing value 0x%x into CNTCR%0d.%s field register", wr_data, id, field_name), UVM_LOW) 

        case (field_name)

       <% if(obj.testBench == 'dii') { %>
       `ifndef CDNS
            inside fields_cntcr_reg : begin
       `else // `ifndef CDNS
            inside {"CntEvtFirst","CntEvtSecond","MinStallPeriod","FilterSel","SSRCount","CounterCtl","InterruptEn","CountClr","CountEn","OverFlowStatus"} : begin
       `endif // `ifndef CDNS
       <% } else {%>
            inside fields_cntcr_reg : begin
       <% } %>
               
                write_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>CNTCR%0d",id)).get_field_by_name(field_name), wr_data);
        
                <% if ((obj.testBench == "fsys") || (obj.testBench == "emu")){ %> 
                // TO BE DELETED AFTER CONCERTO RAL OK
                //write_csr(m_regs.dve0.DVETASCR.BufferEntryNumber, <%=obj.Id%>);
                <% } %>
            end 
            default :
                begin
                    `uvm_info(get_name(),$sformatf("The given field_name %s is not listed below for <%=obj.BlockId%>, Please check",field_name),UVM_LOW)
                    foreach(fields_cntcr_reg[i])
                        `uvm_info(get_name(),$sformatf("fields_cntcr_reg[%0d] = %s", i,fields_cntcr_reg[i] ),UVM_LOW)
                end
        endcase;

    endtask:  write_field_cntcr

    // Write one to enable counting
    task write_count_enable(int id, bit counter_enable = 1'b1, bit from_cfg_obj = 1'b0);
        string field = fields_cntcr_reg[8]; // "count_enable"
        write_field_cntcr(id, field, from_cfg_obj, counter_enable);
        if(!from_cfg_obj) perf_counters.cfg_reg[id].count_enable = counter_enable;
    endtask:  write_count_enable 

    // Write one to clear the counter
    task write_count_clear(int id, counter_clear = 1'b1,bit from_cfg_obj = 1'b0);
        string field = fields_cntcr_reg[7]; // "count_clear"
        write_field_cntcr(id, field, from_cfg_obj, 1);
        if(!from_cfg_obj) perf_counters.cfg_reg[id].count_clear = counter_clear;
    endtask:  write_count_clear 
    //#Stimulus.DII.Pmon.v3.2.Clear
    task write_all_count_clear();
        for(int i=0; i< nPerfCounters  ; i++) begin
            write_count_clear(i);
        end
    endtask:  write_all_count_clear

    // Write one to enable rollover or overflow interrupt
    //#Stimulus.DII.Pmon.v3.2.Overflow32bitWithoutInterupt
    //#Stimulus.DII.Pmon.v3.2.Overflow64bitWithoutInterupt
    //#Stimulus.DII.Pmon.v3.2.Overflow32bitWithInterupt
    //#Stimulus.DII.Pmon.v3.2.Overflow64bitWithInterupt
    task write_interrupt_enable(int id, bit interrupt_enable = 1'b1, bit from_cfg_obj = 1'b0);
        string field = fields_cntcr_reg[6]; // "interrupt_enable"
        write_field_cntcr(id, field, from_cfg_obj, interrupt_enable);
        if(!from_cfg_obj) perf_counters.cfg_reg[id].interrupt_enable = interrupt_enable;

    endtask:  write_interrupt_enable 

    task write_clear_cntsr(int id, bit from_cfg_obj = 1'b0);
        string field = fields_cntcr_reg[4]; // "ssr_count"
        write_field_cntcr(id, field, from_cfg_obj, 0);
        // Clear then set field to 1  ==> Capture upper 63:31 count in CNTSR by default
        write_field_cntcr(id, field, from_cfg_obj, 1); 
    endtask: write_clear_cntsr 

    task write_all_clear_cntsr();
        for(int i=0; i< nPerfCounters  ; i++) begin
            write_clear_cntsr(i);
        end
    endtask:  write_all_clear_cntsr

    /////////////////////////////////////////////////////////////
    //                      Functions for 
    //              Counter control Register (xMCTCR)
    /////////////////////////////////////////////////////////////

    function get_write_data_cntcr(int id, string field_name, output uvm_reg_data_t wr_data);

        case (field_name)

            fields_cntcr_reg[0]  : wr_data = perf_counters.cfg_reg[id].count_event_first;
            fields_cntcr_reg[1]  : wr_data = perf_counters.cfg_reg[id].count_event_second;
            fields_cntcr_reg[2]  : wr_data = perf_counters.cfg_reg[id].minimum_stall_period;
            fields_cntcr_reg[3]  : wr_data = perf_counters.cfg_reg[id].filter_select;
            fields_cntcr_reg[4]  : wr_data = perf_counters.cfg_reg[id].ssr_count;
            fields_cntcr_reg[5]  : wr_data = perf_counters.cfg_reg[id].counter_control;
            fields_cntcr_reg[6]  : wr_data = perf_counters.cfg_reg[id].interrupt_enable;
            fields_cntcr_reg[7]  : wr_data = perf_counters.cfg_reg[id].count_clear;
            fields_cntcr_reg[8]  : wr_data = perf_counters.cfg_reg[id].count_enable;
            fields_cntcr_reg[9]  : wr_data = perf_counters.cfg_reg[id].overflow_status;
            
            default :
                begin
                    `uvm_error(get_name(),$sformatf("ToBeWritten"))
                end
        endcase;

    endfunction:  get_write_data_cntcr

    /////////////////////////////////////////////////////////////
    //                      Read tasks for 
    //              Counter Value Register (xCNTVR)
    //            Counter Saturation Register (xCNTSR)
    /////////////////////////////////////////////////////////////

    task read_cnt_value_reg(int id);
        uvm_reg_data_t fieldVal;
        bit [31:0] fieldVal_bits;
        string field = fields_cntvr_reg[0]; // "CountVal"

        read_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>CNTVR%0d",id)).get_field_by_name(field), fieldVal);
    
        fieldVal_bits = int'(fieldVal);
        perf_counters.count_value[id].cnt_v = fieldVal_bits; 
	//fieldVal = perf_counters.cfg_xcntvr_reg[id].cnt_v;
        perf_counters.cfg_xcntvr_reg[id].cnt_v = fieldVal_bits;
        perf_counters.m_cov_perf_cnt_evt_xCNTVR[id].sample();
        `uvm_info(get_name(), $sformatf("Reading %s field register with value %h", field, fieldVal_bits), UVM_DEBUG)

    endtask: read_cnt_value_reg

    task read_cnt_saturation_reg(int id);
        uvm_reg_data_t fieldVal;
        bit [31:0] fieldVal_bits;
        string field = fields_cntsr_reg[0]; // "CountSatVal"

        read_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>CNTSR%0d",id)).get_field_by_name(field), fieldVal);

        fieldVal_bits = int'(fieldVal);
        perf_counters.count_value[id].cnt_v_str = fieldVal_bits;   
        `uvm_info(get_name(), $sformatf("Reading %s field register with value %h", field, fieldVal_bits), UVM_DEBUG)

    endtask: read_cnt_saturation_reg

    task read_all_cnt_value_reg();
        for ( int i=0; i< nPerfCounters ; i++) begin
            read_cnt_value_reg(i);
        end 
    endtask: read_all_cnt_value_reg

    task read_all_cnt_saturation_reg();     
        for(int i=0; i< nPerfCounters  ; i++) begin
            read_cnt_saturation_reg(i);
        end
    endtask: read_all_cnt_saturation_reg
    
    task read_all_overflow_status();     
        for(int i=0; i< nPerfCounters  ; i++) begin
            read_overflow_status(i);
        end
    endtask: read_all_overflow_status

    task read_overflow_status(int id);
        uvm_reg_data_t fieldVal;
        string field = fields_cntcr_reg[9]; // "overflow_status"

        read_field_cntcr(id, field, fieldVal);
        perf_counters.cfg_reg[id].overflow_status = bit'(fieldVal);

    endtask: read_overflow_status 

    task read_field_cntcr(int id, string field_name, output uvm_reg_data_t rd_data);
 
       `uvm_info(get_name(),
        $sformatf("Reading value 0x%x from CNTCR%0d.%s field register", rd_data, id, field_name), UVM_LOW) 

        case (field_name)

       <% if(obj.testBench == 'dii') { %>
       `ifndef CDNS
            inside fields_cntcr_reg : begin
       `else // `ifndef CDNS
            inside {"CntEvtFirst","CntEvtSecond","MinStallPeriod","FilterSel","SSRCount","CounterCtl","InterruptEn","CountClr","CountEn","OverFlowStatus"} : begin
       `endif // `ifndef CDNS
       <% } else {%>
            inside fields_cntcr_reg : begin
       <% } %>
  
            read_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>CNTCR%0d",id)).get_field_by_name(field_name), rd_data);
  
        end
            default :
                begin
                    `uvm_info(get_name(),$sformatf("The given field_name %s is not listed below, Please check",field_name),UVM_LOW)
                    foreach(fields_cntcr_reg[i])
                        `uvm_info(get_name(),$sformatf("fields_cntcr_reg[%0d] = %s", i,fields_cntcr_reg[i] ),UVM_LOW)
                end
        endcase;


    endtask:  read_field_cntcr
    //Pmon 3.4 feature
    <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>    
    /////////////////////////////////////////////////////////////
    //                      Write tasks for 
    //              BW Registers (xBCNTFR) and (xBCNTMR) 
    /////////////////////////////////////////////////////////////




    task write_all_bw_registers();
        foreach (perf_counters.bw_filter_reg[i]) begin
            `uvm_info(get_name(),$sformatf("Writing all fields of BCNTFR%0d register for <%=obj.BlockId%>",i), UVM_LOW) 
            write_all_bw_reg_fields(i);
        end
    endtask: write_all_bw_registers

    task write_all_bw_reg_fields(int id);
        for(int i=0; i < fields_bcntfr_reg.size()-1; i++) begin
             // -1 to filter_enable register
            // write_count_enable(id, 1'b1, 1'b0); // Will be written separate
            write_field_bcntfr(id, fields_bcntfr_reg[i], 1'b1);
        end
        
        for(int i=0; i < fields_bcntmr_reg.size(); i++) begin
            // -1 to filter_enable register
           // write_count_enable(id, 1'b1, 1'b0); // Will be written separate
           write_field_bcntmr(id, fields_bcntmr_reg[i], 1'b1);
       end
       
    endtask: write_all_bw_reg_fields


    task write_field_bcntmr(int id, string field_name, bit from_cfg_obj=1'b1, uvm_reg_data_t wr_data=0);
        if(from_cfg_obj)begin
            get_write_data_bcntmr(id, field_name, wr_data);
        end
 
       `uvm_info(get_name(),
        $sformatf("For <%=obj.BlockId%> Writing value 0x%x into BCNTFR%0d.%s field register", wr_data, id, field_name), UVM_LOW) 

        case (field_name)

       <% if(obj.testBench == 'dii') { %>
       `ifndef CDNS
            inside fields_bcntmr_reg : begin
       `else // `ifndef CDNS
            inside {"MaskVal"} : begin
       `endif // `ifndef CDNS
       <% } else {%>
            inside fields_bcntmr_reg : begin
       <% } %>
                write_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>BCNTMR%0d",id)).get_field_by_name(field_name), wr_data);
                <% if ((obj.testBench == "fsys") || (obj.testBench == "emu")){ %> 
                // TO BE DELETED AFTER CONCERTO RAL OK
                //write_csr(m_regs.dve0.DVETASCR.BufferEntryNumber, <%=obj.Id%>);
                <% } %>
            end 
            default :
                begin
                    `uvm_info(get_name(),$sformatf("The given field_name %s is not listed below for <%=obj.BlockId%> BW filter registers, Please check",field_name),UVM_LOW)
                    foreach(fields_bcntmr_reg[i])
                        `uvm_info(get_name(),$sformatf("fields_bcntmr_reg[%0d] = %s", i,fields_bcntmr_reg[i] ),UVM_LOW)
                end
        endcase;

    endtask:  write_field_bcntmr

    task write_field_bcntfr(int id, string field_name, bit from_cfg_obj=1'b1, uvm_reg_data_t wr_data=0);
        if(from_cfg_obj)begin
            get_write_data_bcntfr(id, field_name, wr_data);
        end
 
       `uvm_info(get_name(),
        $sformatf("For <%=obj.BlockId%> Writing value 0x%x into BCNTFR%0d.%s field register", wr_data, id, field_name), UVM_LOW) 

        case (field_name)

       <% if(obj.testBench == 'dii') { %>
       `ifndef CDNS
            inside fields_bcntfr_reg : begin
       `else // `ifndef CDNS
            inside {"FilterVal","FilterSel","FilterEn"} : begin
       `endif // `ifndef CDNS
       <% } else {%>
            inside fields_bcntfr_reg : begin
       <% } %>
                write_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>BCNTFR%0d",id)).get_field_by_name(field_name), wr_data);
                <% if ((obj.testBench == "fsys") || (obj.testBench == "emu")){ %> 
                // TO BE DELETED AFTER CONCERTO RAL OK
                //write_csr(m_regs.dve0.DVETASCR.BufferEntryNumber, <%=obj.Id%>);
                <% } %>
            end 
            default :
                begin
                    `uvm_info(get_name(),$sformatf("The given field_name %s is not listed below for <%=obj.BlockId%> BW filter registers, Please check",field_name),UVM_LOW)
                    foreach(fields_bcntfr_reg[i])
                        `uvm_info(get_name(),$sformatf("fields_bcntfr_reg[%0d] = %s", i,fields_bcntfr_reg[i] ),UVM_LOW)
                end
        endcase;

    endtask:  write_field_bcntfr
    // Write BW filter enable 
    task write_filter_enable(int id, bit filter_enable = 1'b1, bit from_cfg_obj = 1'b0);
        string field = fields_bcntfr_reg[2]; // "count_enable"
        write_field_bcntfr(id, field, from_cfg_obj, filter_enable);
        if(!from_cfg_obj) perf_counters.bw_filter_reg[id].filter_enable = filter_enable;
    endtask:  write_filter_enable 

    function get_write_data_bcntfr(int id, string field_name, output uvm_reg_data_t wr_data);

        case (field_name)

            fields_bcntfr_reg[0]  : wr_data = perf_counters.bw_filter_reg[id].filter_value;
            fields_bcntfr_reg[1]  : wr_data = perf_counters.bw_filter_reg[id].filter_select;
            fields_bcntfr_reg[2]  : wr_data = perf_counters.bw_filter_reg[id].filter_enable;
            default :
                begin
                    `uvm_error(get_name(),$sformatf("ToBeWritten"))
                end
        endcase;

    endfunction:  get_write_data_bcntfr

    function get_write_data_bcntmr(int id, string field_name, output uvm_reg_data_t wr_data);

        case (field_name)

            fields_bcntmr_reg[0]  : wr_data = perf_counters.bw_mask_reg[id].mask_value;
            default :
                begin
                    `uvm_error(get_name(),$sformatf("ToBeWritten"))
                end
        endcase;

    endfunction:  get_write_data_bcntmr

    /////////////////////////////////////////////////////////////
    //                      Functions for 
    //             Latency Counter Control Register (xLCNTCR)
    /////////////////////////////////////////////////////////////



    task write_all_lct_fields();
        for(int i=0; i < fields_lcntcr_reg.size()-1; i++) begin
             // -1 to latency_enable register
            // write_latency_enable(1'b1, 1'b0); // Will be written separate
            write_field_lcntcr(fields_lcntcr_reg[i], 1'b1);
        end
       
    endtask: write_all_lct_fields


    task write_field_lcntcr(string field_name, bit from_cfg_obj=1'b1, uvm_reg_data_t wr_data=0);
        if(from_cfg_obj)begin
            get_write_data_lcntcr(field_name, wr_data);
        end
 
       `uvm_info(get_name(),
        $sformatf("For <%=obj.BlockId%> Writing value 0x%x into LCNTCR.%s field register", wr_data, field_name), UVM_LOW) 

        case (field_name)

       <% if(obj.testBench == 'dii') { %>
       `ifndef CDNS
            inside fields_lcntcr_reg : begin
       `else // `ifndef CDNS
            inside {"LatencyPreScale","RdWrLatency","LatencyBinOffset","LatencyCountEn"} : begin
       `endif // `ifndef CDNS
       <% } else {%>
            inside fields_lcntcr_reg : begin
       <% } %>
                write_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>LCNTCR")).get_field_by_name(field_name), wr_data);
                <% if ((obj.testBench == "fsys") || (obj.testBench == "emu")){ %> 
                // TO BE DELETED AFTER CONCERTO RAL OK
                //write_csr(m_regs.dve0.DVETASCR.BufferEntryNumber, <%=obj.Id%>);
                <% } %>
            end 
            default :
                begin
                    `uvm_info(get_name(),$sformatf("The given field_name %s is not listed below for <%=obj.BlockId%> latency filter registers, Please check",field_name),UVM_LOW)
                    foreach(fields_lcntcr_reg[i])
                        `uvm_info(get_name(),$sformatf("fields_lcntcr_reg[%0d] = %s", i,fields_lcntcr_reg[i] ),UVM_LOW)
                end
        endcase;

    endtask:  write_field_lcntcr

    // Write BW filter enable 
    task write_latency_enable(bit latency_enable = 1'b1, bit from_cfg_obj = 1'b0);
        string field = fields_lcntcr_reg[3]; // "latency_enable"
        write_field_lcntcr(field, from_cfg_obj, latency_enable);
        if(!from_cfg_obj) perf_counters.lct_reg.lct_count_enable = latency_enable;
    endtask:  write_latency_enable 

    function get_write_data_lcntcr(string field_name, output uvm_reg_data_t wr_data);

        case (field_name)

            fields_lcntcr_reg[0]  : wr_data = perf_counters.lct_reg.lct_pre_scale;
            fields_lcntcr_reg[1]  : wr_data = perf_counters.lct_reg.lct_type;
            fields_lcntcr_reg[2]  : wr_data = perf_counters.lct_reg.lct_bin_offset;
            fields_lcntcr_reg[3]  : wr_data = perf_counters.lct_reg.lct_count_enable;
            default :
                begin
                    `uvm_error(get_name(),$sformatf("ToBeWritten"))
                end
        endcase;

    endfunction:  get_write_data_lcntcr



    <%}%>
    //Pmon 3.4 feature
    /////////////////////////////////////////////////////////////
    //                      Functions for 
    //             Main Counter Control Register (xMCNTCR)
    /////////////////////////////////////////////////////////////

    function get_write_data_mcntcr(string field_name, output uvm_reg_data_t wr_data);

        case (field_name)

            fields_mcntr_reg[0]  : wr_data = perf_counters.main_cntr_reg.local_count_enable;
            fields_mcntr_reg[1]  : wr_data = perf_counters.main_cntr_reg.local_count_clear;
<%if (obj.BlockId.includes("dve")) {%>
            // #Stimulus.DVE.PerfMon.MasterTrigger
            fields_mcntr_reg[2]  : wr_data = perf_counters.main_cntr_reg.master_count_enable;
<%}%>
            
            default :
                begin
                    `uvm_error(get_name(),$sformatf("ToBeWritten"))
                end
        endcase;

    endfunction:  get_write_data_mcntcr

    task write_field_mcntcr(string field_name, bit from_cfg_obj=1'b1, uvm_reg_data_t wr_data=0);
        if(from_cfg_obj)begin
            get_write_data_mcntcr(field_name, wr_data);
        end
 
       `uvm_info(get_name(),
        $sformatf("For <%=obj.BlockId%> Writing value 0x%x into MCNTCR.%s field register", wr_data,field_name), UVM_LOW) 

        case (field_name)

       <% if(obj.testBench == 'dii') { %>
       `ifndef CDNS
            inside fields_mcntr_reg : begin
       `else // `ifndef CDNS
            inside {"LocalCountEnable","LocalCountClear","MasterCountEnable"} : begin
       `endif // `ifndef CDNS
       <% } else {%>
            inside fields_mcntr_reg : begin
       <% } %>
                write_csr(m_regs.get_block_by_name(blockreg_str).get_reg_by_name($sformatf("<%=regPrefixName()%>MCNTCR")).get_field_by_name(field_name), wr_data);
                <% if ((obj.testBench == "fsys") || (obj.testBench == "emu")){ %> 
                // TO BE DELETED AFTER CONCERTO RAL OK
                //write_csr(m_regs.dve0.DVETASCR.BufferEntryNumber, <%=obj.Id%>);
                <% } %>
            end 
            default :
                begin
                    `uvm_info(get_name(),$sformatf("The given field_name %s is not listed below for <%=obj.BlockId%>, Please check",field_name),UVM_LOW)
                    foreach(fields_mcntr_reg[i])
                        `uvm_info(get_name(),$sformatf("fields_mcntr_reg[%0d] = %s", i,fields_mcntr_reg[i] ),UVM_LOW)
                end
        endcase;

    endtask:  write_field_mcntcr

    // Write one to enable counting
    task write_local_count_enable(bit local_count_enable = 1'b1, bit from_cfg_obj = 1'b0);
        string field = fields_mcntr_reg[0]; // "local count_enable"
        write_field_mcntcr(field, from_cfg_obj, local_count_enable);
        if(!from_cfg_obj) perf_counters.main_cntr_reg.local_count_enable = local_count_enable;
    endtask:  write_local_count_enable 

<%if (obj.BlockId.includes("dve")) {%>
    task write_master_count_enable(bit master_count_enable = 1'b1, bit from_cfg_obj = 1'b0);
        string field = fields_mcntr_reg[2]; // "master_count_enable"
        write_field_mcntcr(field, from_cfg_obj, master_count_enable);
        if(master_count_enable != perf_counters.main_cntr_reg.master_count_enable) begin: was_updated
          foreach(perf_counters.cfg_reg[id]) begin
            // when setting/clearing master_count_enable RTL goes through and sets bits in all counters
            perf_counters.cfg_reg[id].count_enable = master_count_enable;
          end
        end: was_updated
        if(!from_cfg_obj) begin
          perf_counters.main_cntr_reg.master_count_enable = master_count_enable;
        end
    endtask:  write_master_count_enable 
<%}%>

    // Write one to clear the counter
    task write_local_count_clear(bit local_count_clear = 1'b1,bit from_cfg_obj = 1'b0);
        string field = fields_mcntr_reg[1]; // "local count_clear"
        write_field_mcntcr(field, from_cfg_obj, 1);
        if(!from_cfg_obj) perf_counters.main_cntr_reg.local_count_clear = local_count_clear;
    endtask:  write_local_count_clear 
  endclass : perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>
  
    //
    // Accessors
    //
  function uvm_reg_data_t perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>::mask_data(int lsb, int msb);
    uvm_reg_data_t mask_data_val = 0;
    for(int i=0;i<32;i++)begin
        if(i>=lsb &&  i<=msb)begin
            mask_data_val[i] = 1;     
        end
    end
    return mask_data_val;
  endfunction:mask_data


  task perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>::write_csr(uvm_reg_field field, uvm_reg_data_t wr_data);
    int lsb, msb;
    uvm_reg_data_t mask;
    uvm_reg_data_t field_rd_data;
    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().read(status, field_rd_data, .parent(this));
    <% } else {%>
    uvm_reg_addr_t addr;
    bit [31:0] data;
    addr = field.get_parent().get_address(); 
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        //m_chi_csr_vseq.read_csr(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
    <% if ( numIoAiu > 0){ %>
            read_csr<%=csrAccess_io_idx%>(ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% } %>
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    field_rd_data = uvm_reg_data_t'(data);
    <% } %>
    lsb = field.get_lsb_pos();
    msb = lsb + field.get_n_bits() - 1;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Write %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM)
    // and with actual field bits 0
    mask = mask_data(lsb, msb);
    mask = ~mask;
    field_rd_data = field_rd_data & mask;
    // shift write data to appropriate position
    wr_data = wr_data << lsb;
    // then or with this data to get value to write
    wr_data = field_rd_data | wr_data;
    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().write(status, wr_data, .parent(this));
    <% } else {%>
    data=32'(wr_data);
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        //m_chi_csr_vseq.write_csr(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
    <% if ( numIoAiu > 0){ %>
            write_csr<%=csrAccess_io_idx%>(ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% } %>
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    <% } %>
endtask : write_csr

task perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>::read_csr(uvm_reg_field field, output uvm_reg_data_t fieldVal);
    int lsb, msb;
    uvm_reg_data_t mask;
    uvm_reg_data_t field_rd_data;
    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().read(status, field_rd_data, .parent(this));
    <% } else {%>
    uvm_reg_addr_t addr;
    bit [31:0] data;
    addr = field.get_parent().get_address(); 
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        // m_chi_csr_vseq.read_csr(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
    <% if ( numIoAiu > 0){ %>
            read_csr<%=csrAccess_io_idx%>(ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% } %>
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    field_rd_data = uvm_reg_data_t'(data);
    <% } %>
    lsb = field.get_lsb_pos();
    msb = lsb + field.get_n_bits() - 1;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM)
    // AND other bits to 0
    mask = mask_data(lsb, msb);
    field_rd_data = field_rd_data & mask;
    // shift read data by lsb to return field
    fieldVal = field_rd_data >> lsb;
endtask : read_csr


<% if (((obj.testBench == "fsys") || (obj.testBench == "emu")) && (numIoAiu >0)) { %>

task perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>::write_csr<%=csrAccess_io_idx%>(input ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data);
    ioaiu<%=csrAccess_io_idx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq m_iowrnosnp_seq<%=csrAccess_io_idx%>;
    bit [ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_iowrnosnp_seq<%=csrAccess_io_idx%>   = ioaiu<%=csrAccess_io_idx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq::type_id::create("m_iowrnosnp_seq_csr_<%=obj.BlockId%>");
    m_iowrnosnp_seq<%=csrAccess_io_idx%>.m_addr = addr;
    m_iowrnosnp_seq<%=csrAccess_io_idx%>.use_awid = 0;
    m_iowrnosnp_seq<%=csrAccess_io_idx%>.m_axlen = 0;
    m_iowrnosnp_seq<%=csrAccess_io_idx%>.m_size  = 3'b010;
    m_iowrnosnp_seq<%=csrAccess_io_idx%>.m_data[(addr_offset*8)+:32] = data;
    m_iowrnosnp_seq<%=csrAccess_io_idx%>.m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::WXDATA/8) < 32
    m_iowrnosnp_seq<%=csrAccess_io_idx%>.start(m_ioaiu_vseqr<%=csrAccess_io_idx%>);
endtask : write_csr<%=csrAccess_io_idx%>

task perf_cnt_unit_cfg_seq_<%=obj.multiPortCoreId%>::read_csr<%=csrAccess_io_idx%>(input ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    ioaiu<%=csrAccess_io_idx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq m_iordnosnp_seq<%=csrAccess_io_idx%>;
    bit [ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=csrAccess_io_idx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_iordnosnp_seq<%=csrAccess_io_idx%>   = ioaiu<%=csrAccess_io_idx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq::type_id::create("m_iordnosnp_seq_csr_<%=obj.BlockId%>");
    m_iordnosnp_seq<%=csrAccess_io_idx%>.m_addr = addr;
    m_iordnosnp_seq<%=csrAccess_io_idx%>.start(m_ioaiu_vseqr<%=csrAccess_io_idx%>);
   
    rdata = (m_iordnosnp_seq<%=csrAccess_io_idx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=csrAccess_io_idx%>.m_seq_item.m_read_data_pkt.rdata[0] : 0;
    data = rdata[(addr_offset*8)+:32];
    rresp =  (m_iordnosnp_seq<%=csrAccess_io_idx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=csrAccess_io_idx%>.m_seq_item.m_read_data_pkt.rresp : 0;
    if(rresp) begin
        `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",rresp))
    end
endtask : read_csr<%=csrAccess_io_idx%>

<% } %>
/*
##############
listEventArr:
<%=JSON.stringify(obj.listEventArr,null,"\t")%>
##############
listEventStallName
<%=JSON.stringify(obj.listEventStallName)%>
##############
listEventArr:
<%=JSON.stringify(obj.debuglistEventArr,null,"\t")%>
*/
