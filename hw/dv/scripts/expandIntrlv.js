
var paramUtil = require(process.env.WORK_TOP + '/dv/scripts/formatParamUtilities.js')
var sfiPriv_imp = require(process.env.WORK_TOP + '/tb/sub_sys/lib/sfipriv_calc.js');
var _ = require('lodash');
module.exports = {
    formatFunc : formatFunc
}

function formatFunc(obj) {
    var retObj = paramUtil.extAllIntrlvAgents(obj);
    var dummyObj = {};
    dummyObj.param = _.cloneDeep(retObj);
    dummyObj.log2ceil = function number(a) { return Math.ceil(Math.log2(a)); }
    retObj.sfipriv_calc = sfiPriv_imp(dummyObj, console);
    return retObj;
}
