'use strict';

const paramUtil = require('../../scripts/formatParamUtilities.js');
const _ = require('lodash');

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    retObj.isTopLevel = 1;
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc
}
