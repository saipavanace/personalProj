'use strict';

const dmiAgent = require('../../dmi/env/dmiAgent.js');

function formatFunc(obj) {
    var retObj = dmiAgent.formatFunc(obj);
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc: formatFunc,
    unitFunc: dmiAgent.unitFunc
};
