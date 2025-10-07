'use strict';

const diiAgent = require('../../dii/env/diiAgent');

function formatFunc(obj) {
    var retObj = diiAgent.formatFunc(obj);
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc: formatFunc,
    unitFunc: diiAgent.unitFunc
}
