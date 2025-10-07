'use strict';

const ioaiuAgent = require('../../ioaiu/env/ioaiuAgent');

function formatFunc(obj) {
    var retObj = ioaiuAgent.formatFunc(obj);
    retObj.testBench = 'fsys';
    return retObj;
}

module.exports = {
    formatFunc: formatFunc,
    unitFunc: ioaiuAgent.unitFunc
}
