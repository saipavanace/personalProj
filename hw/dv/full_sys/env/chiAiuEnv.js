'use strict';

var chiAgent  = require('../../chi_aiu/env/chiAiuEnv.js');

function formatFunc(obj) {
    var retObj = chiAgent.formatFunc(obj, 1);
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc : formatFunc,
    unitFunc : chiAgent.unitFunc
}
