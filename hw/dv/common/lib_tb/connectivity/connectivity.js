
var paramUtil = require(process.env.WORK_TOP + '/dv/scripts/formatParamUtilities.js')
var sfiPriv_imp = require(process.env.WORK_TOP + '/tb/sub_sys/lib/sfipriv_calc.js');
var _ = require('lodash');

module.exports = {
    formatFunc : formatFunc
}

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    return retObj;
}
