var _ = require('lodash');
const paramUtil = require('../../scripts/formatParamUtilities');
module.exports = {
    formatFunc       : formatFunc,
    unitFunc         : unitFunc
}

function formatFunc(obj) {
    var retObj = _.cloneDeep(obj);
    return retObj;
}
function unitFunc(unitParam, pkgParams) {
    var retObj = paramUtil.unitFuncKeepSmiArr(unitParam, pkgParams);
    return retObj;
}
