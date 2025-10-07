'use strict';
var paramUtil = require('../../scripts/formatParamUtilities.js');


function formatFunc(obj) {
    var retObj  = paramUtil.extAllIntrlvAgents(obj);
    retObj.isTopLevel = 0; // To have prefixed files
    retObj.BlockId = 'apb_debug';// Files are prefixed by this value
    retObj.Block = 'apb_debug';
    retObj.Id = '0';

    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc: formatFunc
};
