// ****************************************************************************
// Class : cdnChiUvmUserActiveDownAgent
// Desc. : This class is used as a basis for active Down Agents. 
// ****************************************************************************
<% var chi_idx=0; obj.AiuInfo.forEach(function(e, indx, array) { %>
<% if(e.fnNativeInterface.includes('CHI')) { 
    var datawidth        = e.interfaces.chiInt.params.wData;
    var nodeid_width     = e.interfaces.chiInt.params.SrcID;
    var addr_width       = e.interfaces.chiInt.params.wAddr;
    var req_rsvdc_width  = e.interfaces.chiInt.params.REQ_RSVDC;
    var data_rsvdc_width = e.interfaces.chiInt.params.DAT_RSVDC;
    var data_check       = 0;
    if( e.interfaces.chiInt.params.enPoison == true){
    var data_poison      = 1; 
    } else {
    var data_poison      = 0; 
    }
    var input_skew       = 1;
%>
class activeChiDownAgent<%=chi_idx%> extends cdnChiUvmAgent;
  

  `uvm_component_utils_begin(activeChiDownAgent<%=chi_idx%>)        
  `uvm_component_utils_end
            <%if(e.fnNativeInterface.includes('CHI')){ %>
                <%let intf_name = '';%>
                <%if(e.fnNativeInterface == 'CHI-B'){%>
                    <%intf_name = 'chi_B_Interface';%>
                <%}else{%>
                    <%intf_name = 'chi_E_Interface';%>
                <%}%>
          `cdnChiDeclareVif(virtual interface <%=intf_name%>_activeDownStream#(.DATA_WIDTH(<%=datawidth%>),
	       	               .NODE_ID_WIDTH(<%=nodeid_width%>),
	       	               .ADDR_WIDTH(<%=addr_width%>),
	       	               .REQ_RSVDC_WIDTH(<%=req_rsvdc_width%>),
	       	               .DATA_RSVDC_WIDTH(<%=data_rsvdc_width%>),
	       	               .DATA_CHECK(<%=data_check%>),
                           .DATA_POISON(<%=data_poison%>)))
<%         }%>

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "activeChiDownAgent<%=chi_idx%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

endclass : activeChiDownAgent<%=indx%>

class passiveChiDownAgent<%=chi_idx%> extends cdnChiUvmAgent;
  

  `uvm_component_utils_begin(passiveChiDownAgent<%=chi_idx%>)        
  `uvm_component_utils_end
        <%if(e.fnNativeInterface.includes('CHI')){ %>
            <%let intf_name = '';%>
            <%if(e.fnNativeInterface == 'CHI-B'){%>
                <%intf_name = 'chi_B_Interface';%>
            <%}else{%>
                <%intf_name = 'chi_E_Interface';%>
            <%}%>
          `cdnChiDeclareVif(virtual interface <%=intf_name%>_passive#(.DATA_WIDTH(<%=datawidth%>),
	       	               .NODE_ID_WIDTH(<%=nodeid_width%>),
	       	               .ADDR_WIDTH(<%=addr_width%>),
	       	               .REQ_RSVDC_WIDTH(<%=req_rsvdc_width%>),
	       	               .DATA_RSVDC_WIDTH(<%=data_rsvdc_width%>),
	       	               .DATA_CHECK(<%=data_check%>),
                           .DATA_POISON(<%=data_poison%>)))
<%         }%>

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new (string name = "activeChiDownAgent<%=chi_idx%>", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new      

endclass : passiveChiDownAgent<%=indx%>
<% chi_idx++; }} )%>
