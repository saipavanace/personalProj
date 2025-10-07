'use strict';

const dceAgent = require('../../dce/env/dceAgent.js');

function formatFunc(obj) {
    var retObj = dceAgent.formatFunc(obj);
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc: formatFunc,
    unitFunc: dceAgent.unitFunc
};
