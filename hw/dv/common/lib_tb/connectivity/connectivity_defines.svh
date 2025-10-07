package <%=obj.BlockId%>_connectivity_defines;

import <%=obj.BlockId%>_smi_agent_pkg::*;

    typedef bit unsigned [63:0] uint64_type;

    typedef logic [<%=obj.nDCEs%>-1:0] AiuDce_connectivity_vec_type;
    typedef logic [<%=obj.nDMIs%>-1:0] AiuDmi_connectivity_vec_type;
    typedef logic [<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec_type;
    typedef logic [(<%=obj.smiObj.WSMINCOREUNITID%>*<%=obj.DutInfo.nAiuConnectedDces%>)-1:0] AiuConnectedDceFunitId_type; // obj.smiObj.WSMINCOREUNITID * obj.DutInfo.nAiuConnectedDces

    AiuDce_connectivity_vec_type AiuDce_connectivity_vec_default = {<%=obj.nDCEs%>{1'b1}}; // We start with all DCEs connected
    AiuDmi_connectivity_vec_type AiuDmi_connectivity_vec_default = {<%=obj.nDMIs%>{1'b0}};
    AiuDmi_connectivity_vec_type AiuDii_connectivity_vec_default = {<%=obj.nDIIs%>{1'b0}};
    AiuConnectedDceFunitId_type AiuConnectedDceFunitId_default = <%=obj.BlockId%>_smi_agent_pkg::CONNECTED_DCE_FUNIT_IDS;


endpackage: <%=obj.BlockId%>_connectivity_defines
