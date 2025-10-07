


function extIntrlvAgents(config, key, configObj) {
    var idx = 0;
    var agentObj = {};
    var agentArr = [];

    config.forEach(function(agent, index, array) {
        if(agent[key]) {
            for(idx = 0; idx < agent[key]; idx++) {
                agentObj = Prep.cloneDeep(agent);
                agentObj.logicalId = index;

                if((typeof(configObj) !== 'undefined') && (configObj.bridgeAiu)) {
                    agentObj.logicalId += configObj.startLogicalId;
                }
                
                if(!idx) { agentObj.interleavedAgent = 0; }
                else { agentObj.interleavedAgent = 1; }
		agentObj.aiu_index = idx;
                agentArr.push(agentObj);
            }
        } else {
            agentObj = Prep.cloneDeep(agent);
            agentObj.logicalId = index;
            if((typeof(configObj) !== 'undefined') && (configObj.bridgeAiu)) {
                agentObj.logicalId += configObj.startLogicalId;
            }
            agentObj.interleavedAgent = 0;
            agentArr.push(agentObj);
        }  
    });

    //console.log('count + %d', agentArr.length);
    return(agentArr);
}
