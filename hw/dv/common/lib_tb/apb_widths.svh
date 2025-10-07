//-------------------------------------------------------------------------------------------------- 
// APB Parameters
//-------------------------------------------------------------------------------------------------- 
<%
var apbObj = {};

//Defaults
if(obj.testBench == "io_aiu") {
    apbObj.wpaddr              = obj.interfaces.apbInt.params.wAddr;
} else if(obj.testBench == "fsys") {
    if((obj.Block === "aiu") || (obj.Block === "io_aiu") || (obj.Block === "aceaiu") || (obj.Block === "chi_aiu")){
        console.log("obj.Block type passed: " + obj.Block +", obj.Id="+ obj.Id +", apb width="+obj.AiuInfo[obj.Id].interfaces.apbInt.params.wAddr);
        apbObj.wpaddr              = obj.AiuInfo[obj.Id].interfaces.apbInt.params.wAddr;
    } else if(obj.Block === "dce") {
        console.log("obj.Block type passed: " + obj.Block +", obj.Id="+ obj.Id +", apb width="+obj.DceInfo[obj.Id].interfaces.apbInt.params.wAddr);
        apbObj.wpaddr              = obj.DceInfo[obj.Id].interfaces.apbInt.params.wAddr;
    } else if(obj.Block === "dmi") {
        console.log("obj.Block type passed: " + obj.Block +", obj.Id="+ obj.Id +", apb width="+obj.DmiInfo[obj.Id].interfaces.apbInt.params.wAddr);
        apbObj.wpaddr              = obj.DmiInfo[obj.Id].interfaces.apbInt.params.wAddr;
    } else if(obj.Block === "dii") {
        console.log("obj.Block type passed: " + obj.Block +", obj.Id="+ obj.Id +", apb width="+obj.DiiInfo[obj.Id].interfaces.apbInt.params.wAddr);
        apbObj.wpaddr              = obj.DiiInfo[obj.Id].interfaces.apbInt.params.wAddr;
    } else if(obj.Block === "dve") {
        console.log("obj.Block type passed: " + obj.Block +", obj.Id="+ obj.Id +", apb width="+obj.DveInfo[obj.Id].interfaces.apbInt.params.wAddr);
        apbObj.wpaddr              = obj.DveInfo[obj.Id].interfaces.apbInt.params.wAddr;
    } else if(obj.Block === "apb_debug" && obj.DebugApbInfo.length > 0) {
        console.log("obj.Block type passed: " + obj.Block +", obj.Id="+ obj.Id +", apb width="+obj.DebugApbInfo[obj.Id].interfaces.apbInterface.params.wAddr);
        apbObj.wpaddr              = obj.DebugApbInfo[obj.Id].interfaces.apbInterface.params.wAddr;
    } else if(obj.Block === "apb_debug") {
        console.log("obj.Block type passed: " + obj.Block +", obj.Id="+ obj.Id +", apb width="+obj.DceInfo[0].interfaces.apbInt.params.wAddr);
        apbObj.wpaddr              = obj.DceInfo[0].interfaces.apbInt.params.wAddr;
   } else {
        console.log("Unexpected obj.Block type passed: " + obj.Block);
        throw('err');
    }
} else {
    apbObj.wpaddr              = obj.DceInfo[0].interfaces.apbInt.params.wAddr;
}
apbObj.wpwrite             = 1;
apbObj.wpsel               = 1;
apbObj.wpenable            = 1;
apbObj.wprdata             = obj.DceInfo[0].interfaces.apbInt.params.wData;
apbObj.wpwdata             = obj.DceInfo[0].interfaces.apbInt.params.wData;
apbObj.wpprot              = obj.DceInfo[0].interfaces.apbInt.params.wProt;
apbObj.wpstrb              = obj.DceInfo[0].interfaces.apbInt.params.wStrb;
apbObj.wpready             = 1;
apbObj.wpslverr            = obj.DceInfo[0].interfaces.apbInt.params.wPSlverr;


%>

parameter WPADDR              = <%=apbObj.wpaddr%>;
parameter WPWRITE             = <%=apbObj.wpwrite%>;
parameter WPSEL               = <%=apbObj.wpsel%>;
parameter WPPROT              = <%=apbObj.wpprot%>;
parameter WPSTRB              = <%=apbObj.wpstrb%>;
parameter WPENABLE            = <%=apbObj.wpenable%>;
parameter WPRDATA             = <%=apbObj.wprdata%>;
parameter WPWDATA             = <%=apbObj.wpwdata%>;
parameter WPREADY             = <%=apbObj.wpready%>;
parameter WPSLVERR            = <%=apbObj.wpslverr%>;
