'use strict';

const dveAgent = require('../../dve/env/dve_agent.js');

function formatFunc(obj) {
    var retObj = dveAgent.formatFunc(obj);
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc: formatFunc,
    unitFunc: dveAgent.unitFunc
};
