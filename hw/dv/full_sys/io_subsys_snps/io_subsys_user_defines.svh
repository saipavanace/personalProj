<%
var numIoAiu = 0; 
var aiu_NumCores = [];
var numAXIAiu = 0;

for(var pidx = 0; pidx < obj.AiuInfo.length ; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
   } else {
       aiu_NumCores[pidx]    = 1;
   }
 }

 for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
        for(var i=0; i<aiu_NumCores[pidx]; i++) {
           numIoAiu++ ; 
         }
    }
 }
%>

   `define SVT_VIRTUAL_SEQR_PATH m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer
   
<% var ioaiu_idx=0; var ioaiu_idx_with_multi_core=0;%> 
   <% for(var pidx=0; pidx<obj.nAIUs; pidx++) { %> 
   <%if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { 
      for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
   `define SVT_IOAIU<%=ioaiu_idx%>_<%=i%>_MASTER_SEQR_PATH2 m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer.master_sequencer[<%=ioaiu_idx_with_multi_core%>]
   `define SVT_IOAIU<%=ioaiu_idx%>_<%=i%>_MASTER_SEQR_PATH1 m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ioaiu_idx_with_multi_core%>].sequencer
   <% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1; } ioaiu_idx = ioaiu_idx+1;} } %>

   `define NUM_IOAIU_SVT_MASTERS <%=ioaiu_idx_with_multi_core%>
   
   `define STRINGIFY(x) `"x`"
