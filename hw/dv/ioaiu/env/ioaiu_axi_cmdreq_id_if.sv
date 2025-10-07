////////////////////////////////////////////////////////////////
// IOAIU AxID and CMDReq ID  Interface
////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

<%
function sumNDP(o) {
  return Object.keys(o).reduce( (sumvar,key)=>sumvar+parseFloat(o[key]||0),0 );
}

var wCmdRspNdp =  sumNDP(obj.AiuInfo[obj.Id].concParams.cmdRspParams);

%>
interface <%=obj.BlockId%>_axi_cmdreq_id_if (input clk, input rst_n);

    import <%=obj.BlockId%>_axi_agent_pkg::*;
    import <%=obj.BlockId%>_smi_agent_pkg::*;


    bit[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0]      w_pt_id;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0]  n_mrc0_mid;
    bit                 valid;

    bit cmd_req_valid;
    bit cmd_req_ready;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGTYPE-1:0] cmd_req_msg_type;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0] cmd_req_msg_id;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:0] cmd_req_target_id;

    bit cmd_rsp_valid;
    bit cmd_rsp_ready;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGTYPE-1:0] cmd_rsp_msg_type;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0] cmd_rsp_r_msg_id;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMISRCID-1:0] cmd_rsp_src_id;
    // For calculating the corr data, in case ofHDR/NDP corr err inj
    bit[<%=wCmdRspNdp%>-1:0] cmd_rsp_ndp;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0] cmd_rsp_msg_id ;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:0] cmd_rsp_target_id ;
    <%if(obj.AiuInfo[obj.Id].interfaces.smiRxInt[1].params.wSmiUser >0) { %>
        bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGUSER-1:0] cmd_rsp_msg_user ;
    <%}%>
    bit CorrErrDetected = 0;

    // Local , used incase of corr error in HDR(msgtyp|srcid) or NDP(RMsgId)
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGTYPE-1:0] m_cmd_rsp_msg_type;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0] m_cmd_rsp_r_msg_id;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMISRCID-1:0] m_cmd_rsp_src_id;
    bit[<%=wCmdRspNdp%>-1:0] m_cmd_rsp_ndp;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0] m_cmd_rsp_msg_id ;
    bit[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:0] m_cmd_rsp_target_id ;
    <%if(obj.AiuInfo[obj.Id].interfaces.smiRxInt[1].params.wSmiUser >0) { %>
        bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGUSER-1:0] m_cmd_rsp_msg_user ;
    <%}%>


    logic[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0] axid_of_received_cmd_req_id;
    logic[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0] axid_of_received_cmd_rsp_id;

    int pending_cmd_req_ar[string][bit[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0]][bit[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]];
    int clk_cycle_after_cmd_rsp[bit[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0]][bit[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]]; //count clk cycles after TB receives cmd rsp

    int axi_cmdreq_id_ar[];
    string cmdtype_smi_id_ar[];
    int dce_funit_id[$] = <%=obj.DutInfo.DceIds%>;

    initial begin
        axi_cmdreq_id_ar = new[2**<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID];
        wait(rst_n === 0);
        foreach (axi_cmdreq_id_ar[idx]) axi_cmdreq_id_ar[idx] = -1;
        forever begin
            wait(rst_n === 1);
            @(posedge clk iff valid === 1);
            axi_cmdreq_id_ar[n_mrc0_mid] = w_pt_id;
        end
    end
    
    initial begin
        cmdtype_smi_id_ar = new[2**<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID];
        wait(rst_n === 0);
        fork
            forever begin
                wait(rst_n === 1);

                @(posedge clk iff (cmd_req_valid & cmd_req_ready) === 1);
                if((cmd_req_msg_type != 8'h70 && cmd_req_msg_type != 8'h71) && !is_cmd_req_to_dce(cmd_req_target_id)) begin
                    axid_of_received_cmd_req_id = axi_cmdreq_id_ar[cmd_req_msg_id];
                    if((cmd_req_msg_type == 8'h20) || (cmd_req_msg_type == 8'h21) ||
                       (cmd_req_msg_type == 8'h10) || (cmd_req_msg_type == 8'h11)) begin
                        cmdtype_smi_id_ar[cmd_req_msg_id] = "WR";
                        if(!pending_cmd_req_ar["WR"].exists(axid_of_received_cmd_req_id))
                            pending_cmd_req_ar["WR"][axid_of_received_cmd_req_id][cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]] = 1;
                        else begin
                            if(!pending_cmd_req_ar["WR"][axid_of_received_cmd_req_id].exists(cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]))
                                pending_cmd_req_ar["WR"][axid_of_received_cmd_req_id][cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]] = 1;
                            else
                                pending_cmd_req_ar["WR"][axid_of_received_cmd_req_id][cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]]++;
                        end
                    end
                    else begin
                        cmdtype_smi_id_ar[cmd_req_msg_id] = "RD";
                        if(!pending_cmd_req_ar["RD"].exists(axid_of_received_cmd_req_id))
                            pending_cmd_req_ar["RD"][axid_of_received_cmd_req_id][cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]] = 1;
                        else begin
                            if(!pending_cmd_req_ar["RD"][axid_of_received_cmd_req_id].exists(cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]))
                                pending_cmd_req_ar["RD"][axid_of_received_cmd_req_id][cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]] = 1;
                            else
                                pending_cmd_req_ar["RD"][axid_of_received_cmd_req_id][cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]]++;
                        end
                    end
                end
            end

            forever begin
                wait(rst_n === 1);
                @(posedge clk iff (cmd_rsp_valid & cmd_rsp_ready) === 1);
                // Check HDR/NDP error
                <% if (obj.DutInfo.useResiliency && (obj.DutInfo.ResilienceInfo.fnResiliencyProtectionType == "ecc")) { %>
                    CorrErrDetected = 0;
                    m_cmd_rsp_msg_id    = cmd_rsp_msg_id   ;
                    m_cmd_rsp_msg_type  = cmd_rsp_msg_type ;
                    m_cmd_rsp_src_id    = cmd_rsp_src_id   ;
                    m_cmd_rsp_target_id = cmd_rsp_target_id;
                    <%if(obj.AiuInfo[obj.Id].interfaces.smiRxInt[1].params.wSmiUser >0) { %>
                        m_cmd_rsp_msg_user  = cmd_rsp_msg_user ;
                    <%}%>
                    m_cmd_rsp_ndp       = cmd_rsp_ndp      ;
                    m_cmd_rsp_r_msg_id  = cmd_rsp_r_msg_id ;
                    if($test$plusargs("inj_cntl") || $test$plusargs("inject_smi_corr_error") ) begin
                        if(<%=obj.BlockId%>_smi_agent_pkg::CORR_ECC_ERR == <%=obj.BlockId%>_smi_agent_pkg::smi_check_err( {<%
                            if(obj.AiuInfo[obj.Id].interfaces.smiRxInt[1].params.wSmiUser >0) { %>
                                cmd_rsp_msg_user,
                            <%}%>
                            cmd_rsp_target_id,cmd_rsp_src_id,cmd_rsp_msg_type,cmd_rsp_msg_id},
                            <%=obj.BlockId%>_smi_agent_pkg::WSMITGTID+<%=obj.BlockId%>_smi_agent_pkg::WSMISRCID+<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGTYPE+<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID,
                            <%=obj.BlockId%>_smi_agent_pkg::WSMIHPROT+<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID+<%=obj.BlockId%>_smi_agent_pkg::WSMISRCID+<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGTYPE+<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID,
                            {
                            <%if(obj.AiuInfo[obj.Id].interfaces.smiRxInt[1].params.wSmiUser >0) { %>
                                m_cmd_rsp_msg_user,
                            <%}%>m_cmd_rsp_target_id,m_cmd_rsp_src_id,m_cmd_rsp_msg_type,m_cmd_rsp_msg_id} )) begin // HDR Error
                                CorrErrDetected = 1;
                            end 
                        if (<%=obj.BlockId%>_smi_agent_pkg::CORR_ECC_ERR == <%=obj.BlockId%>_smi_agent_pkg::smi_check_err( cmd_rsp_ndp, <%=obj.BlockId%>_smi_agent_pkg::get_ndp_len(m_cmd_rsp_msg_type, 0), <%=obj.BlockId%>_smi_agent_pkg::get_ndp_len(m_cmd_rsp_msg_type, 1), m_cmd_rsp_ndp )) begin // NDP Error
                            m_cmd_rsp_r_msg_id  = m_cmd_rsp_ndp[NC_CMD_RSP_RMSGID_MSB:NC_CMD_RSP_RMSGID_LSB];
                            CorrErrDetected = 1;
                        end
                    end
                <% } %>

                if(!(($test$plusargs("inj_cntl") || $test$plusargs("inject_smi_corr_error")) && CorrErrDetected)) begin
                    m_cmd_rsp_msg_type = cmd_rsp_msg_type ;
                    m_cmd_rsp_r_msg_id = cmd_rsp_r_msg_id ;
                    m_cmd_rsp_src_id   = cmd_rsp_src_id   ;
                end

                if(m_cmd_rsp_msg_type == 8'hF1) begin
                    axid_of_received_cmd_rsp_id = axi_cmdreq_id_ar[m_cmd_rsp_r_msg_id];
                    if(cmdtype_smi_id_ar[m_cmd_rsp_r_msg_id] == "WR") begin
                        pending_cmd_req_ar["WR"][axid_of_received_cmd_rsp_id][m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]]--;
                        if(pending_cmd_req_ar["WR"][axid_of_received_cmd_rsp_id][m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]] == 0) begin
                            pending_cmd_req_ar["WR"][axid_of_received_cmd_rsp_id].delete(m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]);
                        end
                    end else begin
                        pending_cmd_req_ar["RD"][axid_of_received_cmd_rsp_id][m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]]--;
                        if(pending_cmd_req_ar["RD"][axid_of_received_cmd_rsp_id][m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]] == 0) begin
                            pending_cmd_req_ar["RD"][axid_of_received_cmd_rsp_id].delete(m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]);
                        end
                    end
                    clk_cycle_after_cmd_rsp[axid_of_received_cmd_rsp_id][m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]] = 1; //5 cycle window per design request
                    fork
                        begin
                            automatic bit[<%=obj.BlockId%>_smi_agent_pkg::WSMISRCID-1:0] tmp_m_cmd_rsp_src_id = m_cmd_rsp_src_id;
                            automatic logic[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0] tmp_axid_of_received_cmd_rsp_id = axi_cmdreq_id_ar[m_cmd_rsp_r_msg_id];
                            automatic int tmp_last_record_cycle = 1;
                            //clk_cycle_after_cmd_rsp valid value is
                            //0: no rsp comes, enable OR checker
                            //1-6: disable OR checker
                            //7: enable OR checker
                            repeat(5) begin
                                @(negedge clk);
                                if(tmp_last_record_cycle == clk_cycle_after_cmd_rsp[tmp_axid_of_received_cmd_rsp_id][tmp_m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]]) begin
                                    clk_cycle_after_cmd_rsp[tmp_axid_of_received_cmd_rsp_id][tmp_m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]]++;
                                    tmp_last_record_cycle = clk_cycle_after_cmd_rsp[tmp_axid_of_received_cmd_rsp_id][tmp_m_cmd_rsp_src_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID]];
                                end
                                else
                                  break;
                            end
                        end
                    join_none
                end
            end
        join_none

    end

    function automatic void clean_cmdreq_id (input bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0] cmdreq_id, input bit[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0] axi_id);
        assert(axi_id == axi_cmdreq_id_ar[cmdreq_id]);
        axi_cmdreq_id_ar[cmdreq_id] = -1;
    endfunction: clean_cmdreq_id

    function automatic bit[<%=obj.BlockId%>_axi_agent_pkg::WAXID-1:0] get_axid (input bit[<%=obj.BlockId%>_smi_agent_pkg::WSMIMSGID-1:0] cmdreq_id);
        return axi_cmdreq_id_ar[cmdreq_id];
    endfunction: get_axid

    function automatic bit  is_cmd_req_to_dce (input bit[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:0] cmd_req_target_id);
        bit[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID-1:0] funit_id = cmd_req_target_id[<%=obj.BlockId%>_smi_agent_pkg::WSMITGTID-1:<%=obj.BlockId%>_smi_agent_pkg::WSMINCOREPORTID];
        foreach(dce_funit_id[idx]) begin
           if(funit_id == dce_funit_id[idx])
               return 1;
        end
        return 0;
    endfunction: is_cmd_req_to_dce
endinterface
