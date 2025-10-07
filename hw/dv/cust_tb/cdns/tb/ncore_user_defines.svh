///////////////////////////////////////////////////////////
// Overriding defines with Concerto system defines
///////////////////////////////////////////////////////////
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var ridx = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var chiA = 0;
   var chiB = 0;
   var chiE = 0;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
        if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A'){
          chiA++;  
         }
        if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B'){
          chiB++;  
         }
        if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'){
          chiE++;  
         }
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx++;
       }
   }
%>
