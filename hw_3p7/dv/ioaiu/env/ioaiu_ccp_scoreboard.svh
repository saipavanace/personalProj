///////////////////////////////////////////////////////////////////////////////

/*! 
 *  \file       ioaiu_scoreboard.sv
 *  \brief      Scoreboard
 *  \details    IOAIU block level scoreboard with support for CCP
 *  \author     David Clarino
 *  \author     Hema Sajja
 *  \version    
 *  \date       2021
 *  \copyright  Arteris IP.
 */

`ifndef QUESTA
    timeunit 1ps;
    timeprecision 1ps;
`endif
<%
    // CCP Tag and Data Array width
    var wDataNoProt = obj.AiuInfo[obj.Id].ccpParams.wData + 1 ; // 1bit of poison
    var wCacheline  = obj.AiuInfo[obj.Id].ccpParams.wAddr - obj.AiuInfo[obj.Id].ccpParams.wCacheLineOffset;
    var wTag        = wCacheline - obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;
                     // Only add when replacement policy is NRU
    var wRP        = (((obj.AiuInfo[obj.Id].ccpParams.nWays > 1) && (obj.AiuInfo[obj.Id].ccpParams.RepPolicy !== 'RANDOM') && (obj.AiuInfo[obj.Id].ccpParams.nRPPorts === 1)) ? 1 : 0);
    var wTagNoProt  = wTag + obj.AiuInfo[obj.Id].ccpParams.wSecurity // TagWidth
                    + obj.AiuInfo[obj.Id].ccpParams.wStateBits // State
                    + wRP;
    var wDataProt = (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo == "PARITYENTRY" ? 1 : (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo == "SECDED" ? (Math.ceil(Math.log2(wDataNoProt + Math.ceil(Math.log2(wDataNoProt)) + 1)) + 1):0));
    var wTagProt = (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo == "PARITYENTRY" ? 1 : (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo == "SECDED" ? (Math.ceil(Math.log2(wTagNoProt + Math.ceil(Math.log2(wTagNoProt)) + 1)) + 1):0));

    var wDataArrayEntry = wDataNoProt + wDataProt;
    var wTagArrayEntry = wTagNoProt + wTagProt;
%>

`undef LABEL
`undef LABEL_ERROR
`define LABEL $sformatf("IOAIU%0d CCP SCB", m_req_aiu_id)
`define LABEL_ERROR $sformatf("IOAIU%0d CCP SCB ERROR", m_req_aiu_id)

typedef class ioaiu_ccp_scoreboard;

class ioaiu_ccp_scoreboard extends ioaiu_scoreboard;
    `uvm_component_param_utils(ioaiu_ccp_scoreboard)

    function new(string name = "ioaiu_ccp_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase
      
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
 
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask : run_phase

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
    endfunction: report_phase

    function void end_of_simulation_phase(uvm_phase phase);
        super.end_of_simulation_phase(phase);
    endfunction // report_phase

endclass : ioaiu_ccp_scoreboard
