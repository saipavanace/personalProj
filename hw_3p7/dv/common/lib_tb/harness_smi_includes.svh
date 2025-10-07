
//File connects internal RTL SFI signals

<% if(obj.testBench=="emu"){ %>
<%
    //Embedded javascript code to figure out
    // number of blocks
    var _child_m = [];
    var wProtbitsPerAgent = [];
    var removeData = [];
    var resetPorts = [];
    var clockPorts = [];
    var uclk = [];
    var urst = [];
    var wFunit = obj.DmiInfo[0].interfaces.uSysIdInt.params.wFUnitIdV[0];
    // Determine if anyone uses DVMs.
    var someoneUsesDvms = 0;
    for(var i = 0; i< obj.AiuInfo.length; i++) {
        //if (obj.AiuInfo[i].cmpInfo.nDvmMsgInFlight) {
        //    someoneUsesDvms = 1;
        //}
        if (obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight) {
            someoneUsesDvms = 1;
        }
    }
    var funitId = [];
    for( var i=0;i<obj.nAIUs;i++) {
      funitId[obj.AiuInfo[i].nUnitId] = obj.AiuInfo[i].FUnitId;
    }
    var portList = function(myObj, retList1, retList2) {
        if(obj.FULL_SYS_TB) {      
            myObj.agentPorts.forEach(function(c) {
                retList1.push(c);
            });
            myObj.dcePorts.forEach(function(c) {
                retList1.push(c);
            });
            myObj.dmiPorts.forEach(function(c) {
                retList1.push(c);
            });
            myObj.uniquePorts.forEach(function(c) {
                retList2.push(c.sig2);
            });
        }
    };
    portList(obj.ClockPorts, clockPorts, uclk);
    portList(obj.ResetPorts, resetPorts, urst);
%>
<%
//Embedded javascript code to figure number of blocks
    var _child_blkid = [];
    var _child_blk   = [];
    var _child_blkSmiIf   = [];
    var pidx = 0;
    var qidx  = 0;
    var sysdii_idx  = 0;
    var idx  = 0;
    var ridx = 0;
    var initiatorAgents = obj.AiuInfo.length ;

    for(pidx = 0; pidx < obj.nAIUs; pidx++) {
        if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
        _child_blkid[pidx] = 'chiaiu' + idx;
        _child_blk[pidx]   = 'chiaiu';
        idx++;
        } else {
        _child_blkid[pidx] = 'ioaiu' + qidx;
        _child_blk[pidx]   = 'ioaiu';
        qidx++;
        }
    }
    for(pidx = 0; pidx < obj.nDCEs; pidx++) {
        ridx = pidx + obj.nAIUs;
        _child_blkid[ridx] = 'dce' + pidx;
        _child_blk[ridx]   = 'dce';
    }
    for(pidx =  0; pidx < obj.nDMIs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs;
        _child_blkid[ridx] = 'dmi' + pidx;
        _child_blk[ridx]   = 'dmi';
    }
    for(pidx = 0; pidx < obj.nDIIs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
        _child_blkid[ridx] = 'dii' + pidx;
        _child_blk[ridx]   = 'dii';
        if(obj.DiiInfo[pidx].configuration){
            sysdii_idx  = pidx;
        }
    }
    for(pidx = 0; pidx < obj.nDVEs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
        _child_blkid[ridx] = 'dve' + pidx;
        _child_blk[ridx]   = 'dve';
    }
%>


<% for(var pidx = 0,qidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
    
         `include "<%=_child_blkid[pidx]%>_harness_smi_widths.svh"
         `include "<%=_child_blkid[pidx]%>_harness_smi_types.svh"
<% } %> 
<% } %> 


<% } %> 
