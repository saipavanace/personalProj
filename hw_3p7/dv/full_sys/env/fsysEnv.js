'use strict';

const paramUtil = require('../../scripts/formatParamUtilities');

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc
}
